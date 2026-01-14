class OrdersController < ApplicationController
  before_action :set_product, only: %i[new create]
  # Garante que só usuários logados finalizem compras (opcional, mas recomendado)
  before_action :authenticate_user!, only: [ :finalize ]

  # GET /orders
  def index
    @orders = Order.all.order(created_at: :desc)
  end

  # GET /orders/1
  def show
    @order = Order.find(params[:id])
  end

  # GET /orders/new
  def new
    @order = Order.new
    @order.product = @product if @product
  end

  # POST /orders
  def create
    @order = Order.new(order_params)
    @order.product = @product if @product

    if @order.product
      @order.total = @order.product.preco * @order.quantidade
    end

    if @order.save
      redirect_to @order, notice: "Pedido criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end


  # --- AÇÃO DE FINALIZAR CARRINHO ---
  def finalize
      @order = current_user.orders.find_by(status: "Carrinho")

      # Pega o valor que veio do input HTML name="tipo_pagamento"
      pagamento = params[:tipo_pagamento]

      # --- DEBUG: Olhe no seu terminal quando clicar em finalizar ---
      puts ">>>>>>>>>>>>>>>> PAGAMENTO RECEBIDO: #{pagamento.inspect}"
      # --------------------------------------------------------------

      if pagamento.blank?
        redirect_to carrinho_path, alert: "Selecione uma forma de pagamento!"
        return
      end

      if @order
        @order.update(
          status: "Recebido",
          endereco: current_user.try(:endereco),
          total: @order.calculate_total,
          tipo_pagamento: pagamento # <--- Aqui salva no banco
        )
        redirect_to root_path, notice: "Pedido enviado!"
      else
        redirect_to carrinho_path, alert: "Erro no pedido."
      end
  end

  def finalizar_pedido
    @order = current_order

    if @order.nil?
      return render json: { error: "Carrinho não encontrado" }, status: :not_found
    end

    # Pegamos os parâmetros vindos do JavaScript (FormData)
    tipo_pagamento = params[:tipo_pagamento]
    troco = params[:troco]

    # Cálculo das taxas
    valor_base = @order.calculate_base_total
    taxa = case tipo_pagamento
    when "Cartão de Crédito" then 1.0309
    when "Cartão de Débito"  then 1.0089
    else 1.00
    end

    total_com_taxa = (valor_base * taxa).round(2)

    # Tenta salvar as informações no banco
    if @order.update(
      tipo_pagamento: tipo_pagamento,
      troco: troco,
      total: total_com_taxa,
      status: "Recebido", # Mudamos para Recebido para aparecer na Cozinha
      user: current_user
    )
      # Limpa a sessão para o cliente poder começar um novo carrinho depois
      session[:order_id] = nil

      # PREPARA A URL DO WHATSAPP
      # Aqui o Rails vai chamar o @order.gerar_mensagem_whatsapp que corrigimos no Model
      telefone = ENV["LOJA_WHATSAPP"] || "5511999999999" # Certifique-se de que essa variável existe

      begin
        mensagem = @order.gerar_mensagem_whatsapp
        url_whatsapp = "https://api.whatsapp.com/send?phone=#{telefone}&text=#{mensagem}"
        render json: { url: url_whatsapp }, status: :ok
      rescue => e
        # Se o erro 500 for dentro do método de mensagem, ele vai printar aqui:
        puts "ERRO NA GERAÇÃO DA MENSAGEM: #{e.message}"
        render json: { error: "Erro ao gerar mensagem: #{e.message}" }, status: :internal_server_error
      end
    else
      render json: { error: @order.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end




  private

    def set_product
      @product = Product.find(params[:product_id]) if params[:product_id]
    end

    def order_params
      # Adicionei :tipo_pagamento aqui por segurança, caso use em outros lugares
      params.require(:order).permit(:cliente_nome, :endereco, :quantidade, :product_id, :tipo_pagamento)
    end

    def current_order
      # 1. Tenta achar pelo ID guardado na sessão (navegador)
      # 2. Se não achar, busca o último pedido 'Carrinho' do usuário logado
      @current_order ||= Order.find_by(id: session[:order_id]) ||
                        current_user.orders.find_by(status: "carrinho")
    end
end

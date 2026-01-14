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
    @order = current_order # Ou o método que você usa para localizar o carrinho atual

    # 1. Pegamos o valor base (soma dos produtos)
    valor_base = @order.calculate_base_total

    # 2. Capturamos o pagamento do formulário (params[:tipo_pagamento])
    # e definimos a taxa exata
    tipo_pagamento = params[:tipo_pagamento]

    taxa = case tipo_pagamento
    when "Cartão de Crédito" then 1.0309
    when "Cartão de Débito"  then 1.0089
    else 1.00 # Pix ou Dinheiro
    end

    # 3. Calculamos o total final arredondado
    total_com_taxa = (valor_base * taxa).round(2)

    # 4. Atualizamos o pedido com todos os dados
    if @order.update(
      tipo_pagamento: tipo_pagamento,
      troco: params[:troco],
      total: total_com_taxa,
      status: "Recebido"
    )
      # 5. Pegamos o telefone das variáveis de ambiente do Render
      telefone = ENV["LOJA_WHATSAPP"] || "5511999999999"

      # 6. Geramos a URL (o modelo usará o @order.total que acabamos de salvar)
      url_whatsapp = "https://api.whatsapp.com/send?phone=#{telefone}&text=#{@order.gerar_mensagem_whatsapp}"

      # 7. Redirecionamento limpo
      redirect_to url_whatsapp, allow_other_host: true
    else
      flash[:error] = "Erro ao processar o pedido. Verifique os dados e tente novamente."
      redirect_to carrinho_path # Verifique se o nome da rota está correto
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
end

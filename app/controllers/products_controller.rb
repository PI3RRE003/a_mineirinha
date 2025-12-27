class ProductsController < ApplicationController
  # 1. Garante que o usuário esteja logado para mexer em produtos (exceto ver a lista)
  before_action :authenticate_user!, except: [ :index, :show ]

  # 2. Garante que apenas o ADMIN possa criar, editar ou excluir (Segurança)
  before_action :check_admin, only: [ :new, :create, :edit, :update, :destroy, :historico_vendas, :arquivados ]

  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
  def index
    @products = Product.where(disponivel: true)
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to products_url, notice: "Produto criado com sucesso! 🧀" }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to products_url, notice: "Produto atualizado com sucesso!" }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  def destroy
    # Em vez de destruir, apenas marcamos como indisponível
    @product.update(disponivel: false)

    respond_to do |format|
      format.html { redirect_to products_url, notice: "O produto foi retirado da vitrine (arquivado) com sucesso." }
      format.json { head :no_content }
    end
  end

  def arquivados
    # Busca apenas os produtos onde 'disponivel' é false
    @products = Product.where(disponivel: false)
  end

  def historico_vendas
    # 1. Começa buscando os pedidos concluídos
    @vendas = Order.where(status: [ "Concluído", "Entregue" ]).order(created_at: :desc)

    # 2. Filtro de Data Inicial
    if params[:data_inicio].present?
      data_inicio = Date.parse(params[:data_inicio]).beginning_of_day
      @vendas = @vendas.where("created_at >= ?", data_inicio)
    end

    # 3. Filtro de Data Final
    if params[:data_final].present?
      data_final = Date.parse(params[:data_final]).end_of_day
      @vendas = @vendas.where("created_at <= ?", data_final)
    end

    # 4. Calcula o total BASEADO no filtro
    @faturamento_total = @vendas.sum(:total)

    # --- LÓGICA DO ITEM MAIS VENDIDO ---
    dados_mais_vendido = OrderItem.where(order_id: @vendas.select(:id))
                                  .group(:product_id)
                                  .sum(:quantidade)
                                  .max_by { |_, quantidade| quantidade }

    if dados_mais_vendido
      @id_campeao = dados_mais_vendido[0]
      @qtd_campea = dados_mais_vendido[1]
      # Tenta achar. Se não achar (foi deletado), retorna nil
      @produto_campeao = Product.find_by(id: @id_campeao)
    else
      @id_campeao = nil
      @qtd_campea = 0
      @produto_campeao = nil
    end

    # --- MUDANÇA: O respond_to AGORA ESTÁ DENTRO DO MÉTODO ---
    respond_to do |format|
      format.html # Renderiza a página normal
      format.pdf do
        render pdf: "Relatorio_Vendas_#{Date.today}",
               template: "products/relatorio_pdf",
               layout: "pdf",
               orientation: "Landscape",
               page_size: "A4"
      end
    end
  end

  private

  def set_product
    # Se você estiver usando Rails 8 ou 7.1+ com params.expect
    @product = Product.find(params.expect(:id))
    # Se der erro aqui, volte para: @product = Product.find(params[:id])
  end

  def product_params
    # Se estiver usando Rails 8 / 7.1+
    params.expect(product: [ :nome, :descricao, :preco, :disponivel, :gera_pontos, :imagem ])
    # Se der erro, use o padrão antigo:
    # params.require(:product).permit(:nome, :descricao, :preco, :disponivel, :gera_pontos, :imagem)
  end

  def check_admin
    unless current_user.try(:is_admin?)
      redirect_to root_path, alert: "Apenas funcionários podem entrar na cozinha! 👨‍🍳🚫"
    end
  end
end

class ProductsController < ApplicationController
  # 1. Garante que o usuário esteja logado para mexer em produtos (exceto ver a lista)
  before_action :authenticate_user!, except: [ :index, :show ]

  # 2. Garante que apenas o ADMIN possa criar, editar ou excluir (Segurança)
  before_action :check_admin, only: [ :new, :create, :edit, :update, :destroy ]

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
        format.html { redirect_to @product, notice: "Produto criado com sucesso! 🧀" }
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
        format.html { redirect_to @product, notice: "Produto atualizado com sucesso!", status: :see_other }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  # DELETE /products/1
  def destroy
    # Em vez de destruir, apenas marcamos como indisponível
    @product.update(disponivel: false)

    respond_to do |format|
      format.html { redirect_to products_url, notice: "O produto foi retirado da vitrine (arquivado) com sucesso." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def product_params
      # AQUI ESTÁ A MUDANÇA DA FIDELIDADE:
      # Adicionei o :gera_pontos na lista permitida
      params.expect(product: [ :nome, :descricao, :preco, :disponivel, :gera_pontos, :imagem ])
    end

    # Função de segurança para barrar curiosos
    def check_admin
      unless current_user.is_admin?
        redirect_to root_path, alert: "Apenas funcionários podem entrar na cozinha! 👨‍🍳🚫"
      end
    end
end

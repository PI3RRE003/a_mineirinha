class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  def dashboard
    # Pega todos os pedidos que NÃO são carrinho (ou seja, pendentes, entregues, etc)
    # E ordena do mais recente para o mais antigo
    @orders = Order.where.not(status: "carrinho").order(created_at: :desc)
  end

  private

  # Segurança extra: se não for admin, chuta para a home
  def check_admin
    unless current_user.is_admin?
      redirect_to root_path, alert: "Acesso negado! Área restrita da cozinha."
    end
  end
end

class CozinhaController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  def show
    # Esconde Carrinho, Concluído E Cancelado da tela principal
    @pedidos = Order.where.not(status: [ "Carrinho", "Concluído", "Cancelado" ])
                    .order(created_at: :desc)
  end
  # NOVA AÇÃO
  def vendas
    # O histórico mostra Concluídos e Cancelados agora
    @vendas = Order.where(status: [ "Concluído", "Cancelado" ]).order(updated_at: :desc)

    # Soma apenas o que foi realmente vendido (Concluído)
    @faturamento_total = Order.where(status: "Concluído").sum(:total)
  end
  # NOVA AÇÃO
  def concluir
    @pedido = Order.find(params[:id])
    @pedido.update(status: "Concluído")

    redirect_to cozinha_path, notice: "Pedido ##{@pedido.id} finalizado e arquivado!"
  end

  def cancelar
    @pedido = Order.find(params[:id])
    @pedido.update(status: "Cancelado")

    # Opcional: Aqui você poderia estornar pontos ou mandar email
    redirect_to cozinha_path, alert: "Pedido ##{@pedido.id} foi cancelado/recusado."
  end

  private

  def check_admin
    unless current_user.try(:is_admin?)
      redirect_to root_path, alert: "Acesso restrito à equipe da cozinha!"
    end
  end
end

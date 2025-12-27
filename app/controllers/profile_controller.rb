class ProfileController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user

    # Lógica de pontos (Fidelidade)
    # O operador || 0 garante que não quebre se pontos for nil
    @pontos_atuais = (@user.pontos || 0) % 10

    # --- CORREÇÃO AQUI ---
    # Queremos ver TUDO que NÃO É 'carrinho'.
    # Isso inclui automaticamente: Recebido, Concluído, Cancelado, etc.
    @pedidos_antigos = current_user.orders
                                   .where.not(status: [ "carrinho", "Carrinho" ]) # Blindado contra maiúsculas/minúsculas
                                   .order(created_at: :desc)
  end

  def cancelar_pedido
    @pedido = current_user.orders.find(params[:id])

    # Verifica status ignorando diferenças de maiúscula/minúscula
    if @pedido.status.to_s.downcase == "recebido"
      @pedido.update(status: "Cancelado")
      redirect_to perfil_usuario_path, notice: "Pedido ##{@pedido.id} foi cancelado."
    else
      redirect_to perfil_usuario_path, alert: "Este pedido não pode ser cancelado pois já foi processado."
    end
  end
end

module ApplicationHelper
  def loja_aberta?
    # Busca o primeiro administrador do sistema
    admin = User.find_by(is_admin: true)

    # A loja está aberta APENAS se o admin marcou como aberta manualmente
    admin&.loja_aberta_manual?
  end
end

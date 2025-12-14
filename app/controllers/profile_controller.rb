class ProfileController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    # Lógica simples: O cartão tem 10 espaços.
    # Se o usuário tem 12 pontos, ele tem 1 cartão cheio e 2 pontos no novo.
    # O resto da divisão (%) ajuda a mostrar só os pontos do cartão atual.
    @pontos_atuais = @user.pontos % 10
  end
end

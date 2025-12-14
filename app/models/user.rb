class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :orders
  def cart_item_count
    # 1. Procura um pedido do usuário que tenha o status 'carrinho'
    pedido_atual = orders.find_by(status: "carrinho")

    # 2. Se achou o pedido, soma a quantidade dos itens. Se não, retorna 0.
    if pedido_atual
      pedido_atual.order_items.sum(:quantidade)
    else
      0
    end
  end
end

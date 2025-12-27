class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  def total_price
    product.preco * quantidade
  end
end

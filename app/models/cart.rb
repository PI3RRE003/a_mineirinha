class Cart < ApplicationRecord
  belongs_to :user

has_many :cart_items, dependent: :destroy

  def total_price
    car.items.sum { |item| item.total_price }
  end
end

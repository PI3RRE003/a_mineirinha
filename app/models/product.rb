class Product < ApplicationRecord
  has_many :order_items
  has_one_attached :imagem
end

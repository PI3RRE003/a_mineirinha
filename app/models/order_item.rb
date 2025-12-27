class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  before_create :snapshot_name

  private
  def snapshot_name
    self.product_name = product.nome
  end
end

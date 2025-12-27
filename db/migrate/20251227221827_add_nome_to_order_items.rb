class AddNomeToOrderItems < ActiveRecord::Migration[8.1]
  def change
    add_column :order_items, :product_name, :string
  end
end

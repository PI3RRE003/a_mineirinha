class AddTrocoToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :troco, :string
  end
end

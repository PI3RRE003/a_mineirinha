class AddPontosEntreguesToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :pontos_entregues, :boolean, default: false
  end
end

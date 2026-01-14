class ChangeTotalToDecimalInOrders < ActiveRecord::Migration[7.0]
  def change
    # Alteramos a coluna total para decimal
    # precision: 10 (total de dígitos)
    # scale: 2 (dígitos após a vírgula)
    change_column :orders, :total, :decimal, precision: 10, scale: 2, default: 0.0
  end
end

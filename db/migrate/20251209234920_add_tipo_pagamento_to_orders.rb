class AddTipoPagamentoToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :tipo_pagamento, :string
  end
end

class AddObservacoesToOrderItems < ActiveRecord::Migration[8.1]
  def change
    add_column :order_items, :observacoes, :text
  end
end

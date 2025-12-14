class AddGeraPontosToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :gera_pontos, :boolean
  end
end

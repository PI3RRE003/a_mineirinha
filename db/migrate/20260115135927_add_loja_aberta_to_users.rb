class AddLojaAbertaToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :loja_aberta_manual, :boolean
  end
end

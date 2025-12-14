class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :nome
      t.text :descricao
      t.decimal :preco, precision: 10, scale: 2
      t.boolean :disponivel

      t.timestamps
    end
  end
end

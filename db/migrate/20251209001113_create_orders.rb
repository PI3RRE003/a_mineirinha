class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      # 1. Vincula o pedido ao Pão de Queijo (obrigatório)
      t.references :product, null: false, foreign_key: true

      # 2. Dados do Cliente (substituindo o user logado para facilitar venda rápida)
      t.string :cliente_nome
      t.text :endereco

      # 3. Detalhes da Compra
      t.integer :quantidade, default: 1
      t.decimal :total, precision: 10, scale: 2 # Ex: 150.50
      t.string :status, default: "Pendente"     # Ex: Pendente, Pago, Enviado

      t.timestamps
    end
  end
end

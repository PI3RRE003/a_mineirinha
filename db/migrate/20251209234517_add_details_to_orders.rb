class AddDetailsToOrders < ActiveRecord::Migration[7.1] # Verifique se a versão é 7.1 ou 8.1 conforme seu Rails
  def change
    # Adicionando as colunas que faltam para o código funcionar
    add_column :orders, :endereco, :text
    add_column :orders, :cliente_nome, :string

    # Adicionando um valor padrão para pedidos antigos não quebrarem
    change_column_default :orders, :status, from: nil, to: "Carrinho"
  end
end

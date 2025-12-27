class AddCamposToUsers < ActiveRecord::Migration[7.1]
  def change
    # Só adiciona se NÃO existir
    add_column :users, :nome, :string unless column_exists?(:users, :nome)
    add_column :users, :telefone, :string unless column_exists?(:users, :telefone)
    add_column :users, :endereco, :string unless column_exists?(:users, :endereco)

    # Pontos (Fidelidade)
    add_column :users, :pontos, :integer, default: 0 unless column_exists?(:users, :pontos)
  end
end

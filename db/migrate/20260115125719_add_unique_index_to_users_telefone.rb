class AddUniqueIndexToUsersTelefone < ActiveRecord::Migration[8.1]
  def change
    add_index :users, :telefone, unique: true
  end
end

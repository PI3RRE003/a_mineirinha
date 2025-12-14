class AddPontosToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :pontos, :integer, default: 0
  end
end

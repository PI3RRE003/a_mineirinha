class AddDataNascimentoToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :data_nascimento, :date
  end
end

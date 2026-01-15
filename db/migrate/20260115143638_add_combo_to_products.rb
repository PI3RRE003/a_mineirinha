class AddComboToProducts < ActiveRecord::Migration[7.1]
  def change
    # Adicione o 'default: false' aqui dentro
    add_column :products, :is_combo, :boolean, default: false
  end
end

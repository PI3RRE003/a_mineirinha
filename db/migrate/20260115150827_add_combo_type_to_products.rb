class AddComboTypeToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :combo_type, :string
  end
end

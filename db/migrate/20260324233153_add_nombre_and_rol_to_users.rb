class AddNombreAndRolToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :nombre, :string, null: false
    add_column :users, :rol, :integer, default: 0, null: false
  end
end

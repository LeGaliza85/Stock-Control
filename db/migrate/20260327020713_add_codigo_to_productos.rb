class AddCodigoToProductos < ActiveRecord::Migration[8.1]
  def change
    add_column :productos, :codigo, :string, limit: 20
    add_index :productos, :codigo, unique: true
  end
end

class RemoveCategoriaFromProductos < ActiveRecord::Migration[8.1]
  def change
    remove_column :productos, :categoria, :string
  end
end

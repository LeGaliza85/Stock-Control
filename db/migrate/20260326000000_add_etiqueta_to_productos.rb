class AddEtiquetaToProductos < ActiveRecord::Migration[8.1]
  def change
    add_column :productos, :etiqueta, :integer, default: 0
    add_index :productos, :etiqueta
  end
end

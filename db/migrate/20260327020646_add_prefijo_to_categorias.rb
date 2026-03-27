class AddPrefijoToCategorias < ActiveRecord::Migration[8.1]
  def change
    add_column :categorias, :prefijo, :string, limit: 10
    add_index :categorias, :prefijo, unique: true
  end
end

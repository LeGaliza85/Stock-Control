class AddCategoriaIdToProductos < ActiveRecord::Migration[8.1]
  def up
    add_reference :productos, :categoria

    # Migrar datos: crear categorías desde valores únicos y actualizar productos
    execute <<-SQL.squish
      INSERT INTO categorias (nombre, created_at, updated_at)
      SELECT DISTINCT categoria, NOW(), NOW()
      FROM productos
      WHERE categoria IS NOT NULL AND categoria != ''
    SQL

    execute <<-SQL.squish
      UPDATE productos
      SET categoria_id = (SELECT id FROM categorias WHERE categorias.nombre = productos.categoria)
      WHERE categoria IS NOT NULL AND categoria != ''
    SQL

    change_column_null :productos, :categoria_id, false
  end

  def down
    remove_reference :productos, :categoria
  end
end

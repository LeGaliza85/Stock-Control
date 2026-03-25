class CreateProductos < ActiveRecord::Migration[8.1]
  def change
    create_table :productos do |t|
      t.string :nombre, null: false
      t.text :descripcion, null: false
      t.decimal :precio_compra, precision: 10, scale: 2, null: false
      t.decimal :precio_venta, precision: 10, scale: 2, null: false
      t.integer :estado, null: false
      t.integer :anio_aprox
      t.string :uso
      t.string :categoria, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :productos, :categoria
    add_index :productos, :estado
  end
end

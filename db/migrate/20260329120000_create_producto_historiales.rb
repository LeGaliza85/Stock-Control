class CreateProductoHistoriales < ActiveRecord::Migration[8.1]
  def change
    create_table :producto_historiales do |t|
      t.references :producto, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :nullify }
      t.string :campo
      t.text :valor_anterior
      t.text :valor_nuevo
      t.text :resumen
      t.datetime :created_at

      t.index [:producto_id, :created_at]
    end
  end
end

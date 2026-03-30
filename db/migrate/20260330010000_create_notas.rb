class CreateNotas < ActiveRecord::Migration[8.1]
  def change
    create_table :notas do |t|
      t.references :producto, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.text :contenido, limit: 1000
      t.timestamps

      t.index [:producto_id, :created_at]
      t.index [:user_id, :created_at]
    end
  end
end

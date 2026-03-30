class CreateProductoVistos < ActiveRecord::Migration[8.1]
  def change
    create_table :producto_vistos do |t|
      t.references :producto, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.datetime :visto_at

      t.index [:user_id, :visto_at]
      t.index [:producto_id, :visto_at]
      t.index [:user_id, :producto_id], unique: true
    end
  end
end

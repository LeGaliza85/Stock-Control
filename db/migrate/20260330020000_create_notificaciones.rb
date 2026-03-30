class CreateNotificaciones < ActiveRecord::Migration[8.1]
  def change
    create_table :notificaciones do |t|
      t.references :user, null: false, foreign_key: true
      t.references :producto, null: false, foreign_key: true
      t.string :tipo, null: false, default: "nuevo_producto"
      t.boolean :leida, default: false

      t.timestamps
    end

    add_index :notificaciones, :leida
    add_index :notificaciones, :created_at
  end
end

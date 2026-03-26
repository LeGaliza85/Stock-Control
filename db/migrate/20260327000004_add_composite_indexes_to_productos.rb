class AddCompositeIndexesToProductos < ActiveRecord::Migration[8.1]
  def change
    add_index :productos, [ :categoria_id, :created_at ]
    add_index :productos, [ :user_id, :created_at ]
    add_index :productos, [ :estado, :created_at ]
  end
end

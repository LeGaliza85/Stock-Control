class AddLastUpdatedByToProductos < ActiveRecord::Migration[8.1]
  def change
    add_reference :productos, :last_updated_by, null: true, foreign_key: { to_table: :users }
  end
end

class RemoveUsoFromProductos < ActiveRecord::Migration[8.1]
  def change
    remove_column :productos, :uso, :string
  end
end

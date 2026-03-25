class RemoveAnioAproxFromProductos < ActiveRecord::Migration[8.1]
  def change
    remove_column :productos, :anio_aprox, :integer
  end
end

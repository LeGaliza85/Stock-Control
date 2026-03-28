class AddEmbeddingToProductos < ActiveRecord::Migration[8.1]
  def change
    add_column :productos, :embedding, :text
  end
end

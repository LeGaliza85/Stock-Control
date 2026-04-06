class AddEmbeddingToProductos < ActiveRecord::Migration[8.1]
  def change
    enable_extension "vector"
    add_column :productos, :embedding, :vector, limit: 512
  end
end

class GenerateEmbeddingJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(producto_id)
    producto = Producto.find_by(id: producto_id)
    return unless producto&.fotos&.attached?

    embeddings = []

    producto.fotos.each do |foto|
      begin
        foto.blob.open do |file|
          emb = ImageEmbeddingService.generate(file.path)
          if emb.present?
            emb = emb.first if emb.first.is_a?(Array)
            embeddings << emb
          end
        end
      rescue => e
        Rails.logger.error "Error al extraer embedding de foto: #{e.message}"
      end
    end

    return unless embeddings.any?

    if embeddings.size == 1
      producto.update!(embedding: embeddings.first)
    else
      # Promediar (mean pooling) todos los embeddings para obtener una representación
      # global de todas las fotos (útil para pgvector donde solo hay 1 vector por fila)
      dimensions = embeddings.first.size
      avg_embedding = Array.new(dimensions, 0.0)
      
      embeddings.each do |emb|
        emb.each_with_index do |val, i|
          avg_embedding[i] += val
        end
      end
      
      avg_embedding.map! { |val| val / embeddings.size }
      
      # Normalización L2 del vector promedio (recomendado para similitud coseno)
      magnitude = Math.sqrt(avg_embedding.sum { |v| v * v })
      if magnitude > 0
        avg_embedding.map! { |v| v / magnitude }
      end
      
      producto.update!(embedding: avg_embedding)
    end
  end
end

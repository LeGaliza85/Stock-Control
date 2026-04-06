class SimilaritySearchService
  def self.buscar(embedding, limit: 5)
    return [] if embedding.blank?

    begin
      query_vector = embedding.is_a?(String) ? JSON.parse(embedding) : embedding
      query_vector = query_vector.first if query_vector.first.is_a?(Array)
    rescue
      return []
    end

    begin
      Producto.where.not(embedding: nil)
              .nearest_neighbors(:embedding, query_vector, distance: "cosine")
              .first(limit)
              .map do |p|
                distance = p.try(:neighbor_distance) || 0
                similarity = 1.0 - distance # cosine distance is 1 - cosine similarity
                { producto: p, score: similarity * 100 }
              end
              .select { |s| s[:score] > 30 } # Minimum 30% similarity
    rescue => e
      Rails.logger.error "Error in SimilaritySearchService: #{e.message}"
      []
    end
  end
end

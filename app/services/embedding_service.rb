class EmbeddingService
  def initialize(producto)
    @producto = producto
  end

  def call
    return unless @producto.fotos.attached?

    embeddings = []

    @producto.fotos.each do |foto|
      begin
        blob = foto.blob
        image_binary = blob.download
        base64_encoded = Base64.strict_encode64(image_binary)
        image_data = "data:#{blob.content_type};base64,#{base64_encoded}"

        analyzer = ImageAnalyzerService.new(@producto.user)
        embedding_json = analyzer.get_embedding_from_image(image_data)
        embeddings << JSON.parse(embedding_json) if embedding_json
      rescue => e
        Rails.logger.error "Error generando embedding para foto: #{e.message}"
      end
    end

    if embeddings.any?
      @producto.update_column(:embedding, embeddings.to_json)
    end
  end
end

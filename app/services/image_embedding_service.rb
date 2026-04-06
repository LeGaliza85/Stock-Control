class ImageEmbeddingService
  class << self
    def clip_model
      @clip_model ||= Clip::Model.new(download_models: true)
    end

    def generate(path)
      # Returns an Array of 512 floats
      clip_model.encode_image(path)
    rescue StandardError => e
      Rails.logger.error "ImageEmbeddingService Error: #{e.message}"
      nil
    end

    def reset_model!
      @clip_model = nil
    end

    def model_loaded?
      !@clip_model.nil?
    end
  end
end

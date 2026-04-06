# frozen_string_literal: true

require "clip"

Rails.application.config.to_prepare do
  # Lazy-load the model, but we can trigger initialization here so it downloads
  # the model files if they don't exist and loads them into memory.
  # It takes a few seconds on boot but makes the first web request fast.
  begin
    Rails.logger.info "Pre-loading CLIP model..."
    ImageEmbeddingService.clip_model
    Rails.logger.info "CLIP model loaded successfully."
  rescue => e
    Rails.logger.warn "Failed to pre-load CLIP model: #{e.message}"
  end
end

class ImageAnalysisController < ApplicationController
  def analyze
    image_data = params[:image_data]

    unless image_data.present?
      render json: { error: "Se requiere imagen" }, status: :bad_request
      return
    end

    analyzer = ImageAnalyzerService.new(current_user)

    begin
      result = analyzer.analyze(image_data)

      if result[:error]
        status = result[:necesita_config] ? :payment_required : :unprocessable_entity
        render json: result, status: status
      else
        render json: result
      end
    rescue => e
      Rails.logger.error("Image analysis error: #{e.message}")
      render json: { error: "Error al analizar imagen: #{e.message}" }, status: :internal_server_error
    end
  end

  def services
    analyzer = ImageAnalyzerService.new(current_user)
    render json: { services: analyzer.available_services }
  end

  def update_config
    user_params = params.permit(:ia_service, :moondream_mode)

    if current_user.update(user_params)
      redirect_to config_ia_path, notice: "Configuración guardada correctamente."
    else
      redirect_to config_ia_path, alert: "Error: #{current_user.errors.full_messages.join(', ')}"
    end
  end
end

class ConfiguracionController < ApplicationController
  GEMINI_MODELS = {
    "gemini-2.5-flash" => { name: "Gemini 2.5 Flash", description: "Modelo rápido y preciso. Recomendado." },
    "gemini-3-flash-preview" => "Gemini 3 Flash Preview",
    "gemini-2.5-flash-lite" => "Gemini 2.5 Flash Lite"
  }.freeze

  def ia
    @ia_services = %w[openrouter gemini].map do |service|
      stats = IaUsage.usage_stats(current_user, service)
      {
        id: service,
        name: service_name(service),
        description: service_description(service),
        used_today: stats[:used_today],
        limit_today: stats[:limit_today],
        used_month: stats[:used_month],
        limit_month: stats[:limit_month],
        label: stats[:label]
      }
    end

    @current_service = current_user.ia_service || "gemini"
    @gemini_models = GEMINI_MODELS
    @current_gemini_model = current_user.gemini_model || "gemini-2.5-flash"
  end

  private

  def service_name(id)
    {
      "gemini" => "Google Gemini",
      "openrouter" => "OpenRouter (Gemini)"
    }[id]
  end

  def service_description(id)
    {
      "gemini" => "API de Google. Selección de modelos disponibles.",
      "openrouter" => "Gemini a través de OpenRouter con fallback automático entre modelos."
    }[id]
  end
end

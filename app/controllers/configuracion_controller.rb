class ConfiguracionController < ApplicationController
  def ia
    gemini_stats = IaUsage.usage_stats(current_user, "gemini")
    moondream_stats = IaUsage.usage_stats(current_user, "moondream")

    @gemini_used_today = gemini_stats[:used_today]
    @gemini_limit = gemini_stats[:limit_today]
    @gemini_label = gemini_stats[:label]
    @gemini_used_month = gemini_stats[:used_month]
    @gemini_monthly_limit = gemini_stats[:limit_month]

    @moondream_used_today = moondream_stats[:used_today]
    @moondream_limit = moondream_stats[:limit_today]
    @moondream_label = moondream_stats[:label]
    @moondream_used_month = moondream_stats[:used_month]
    @moondream_monthly_limit = moondream_stats[:limit_month]
  end
end

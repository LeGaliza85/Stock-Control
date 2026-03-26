class IaUsage < ApplicationRecord
  belongs_to :user

  LIMITS = {
    "gemini" => { daily: 1500, monthly: 45000, label: "solicitudes" },
    "moondream" => { daily: 5000, monthly: 150000, label: "solicitudes" }
  }.freeze

  def self.record_request(user, ia_service)
    usage = find_or_initialize_by(user: user, ia_service: ia_service)

    if usage.new_record?
      usage.requests_today = 1
      usage.requests_this_month = 1
      usage.last_reset_date = Date.current
      usage.last_reset_month = Date.current.month
      usage.save!
      return usage
    end

    reset_if_needed(usage)
    usage.increment!(:requests_today)
    usage.increment!(:requests_this_month)
    usage
  end

  def self.remaining_today(user, ia_service)
    usage = find_by(user: user, ia_service: ia_service)
    return limit_for(ia_service) unless usage

    reset_if_needed(usage)
    [ limit_for(ia_service) - usage.requests_today, 0 ].max
  end

  def self.used_today(user, ia_service)
    usage = find_by(user: user, ia_service: ia_service)
    return 0 unless usage

    reset_if_needed(usage)
    usage.requests_today
  end

  def self.used_this_month(user, ia_service)
    usage = find_by(user: user, ia_service: ia_service)
    return 0 unless usage

    reset_if_needed(usage)
    usage.requests_this_month
  end

  def self.limit_for(ia_service)
    LIMITS.dig(ia_service, :daily) || 0
  end

  def self.limit_label(ia_service)
    LIMITS.dig(ia_service, :label) || "solicitudes"
  end

  def self.monthly_limit_for(ia_service)
    LIMITS.dig(ia_service, :monthly) || 0
  end

  def self.usage_stats(user, ia_service)
    usage = find_by(user: user, ia_service: ia_service)

    unless usage
      return {
        used_today: 0,
        limit_today: limit_for(ia_service),
        used_month: 0,
        limit_month: monthly_limit_for(ia_service),
        label: limit_label(ia_service)
      }
    end

    reset_if_needed(usage)
    {
      used_today: usage.requests_today,
      limit_today: limit_for(ia_service),
      used_month: usage.requests_this_month,
      limit_month: monthly_limit_for(ia_service),
      label: limit_label(ia_service)
    }
  end

  private

  def self.reset_if_needed(usage)
    needs_save = false
    current_month = Date.current.month

    if usage.last_reset_date != Date.current
      usage.requests_today = 0
      usage.last_reset_date = Date.current
      needs_save = true
    end

    if usage.last_reset_month != current_month
      usage.requests_this_month = 0
      usage.last_reset_month = current_month
      needs_save = true
    end

    usage.save! if needs_save
  end
end

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?, :current_user
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def current_user
      resume_session
      Current.user
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      session_from_cookie = find_session_by_cookie
      if session_from_cookie
        Current.session = session_from_cookie
      else
        Current.session = nil
      end
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_url
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      if Current.session
        Current.session.destroy
        Current.session = nil
      end
      cookies.delete(:session_id)
    end

    def require_no_visitante
      if current_user&.visitante?
        redirect_to productos_path, alert: "No tienes permiso para acceder a esta función."
      end
    end

    def require_admin
      unless current_user&.admin?
        redirect_to productos_path, alert: "No tienes permiso para realizar esta acción."
      end
    end
end

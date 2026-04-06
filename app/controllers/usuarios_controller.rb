class UsuariosController < ApplicationController
  before_action :require_admin, only: [ :new, :create, :edit, :update, :destroy ]

  def index
    redirect_to gestionar_usuarios_path
  end

  def gestionar
    @usuarios = User.order(:nombre)
  end

  def registrados
    @usuarios = User.where.not(registered_at: nil).order(registered_at: :desc)
  end

  def new
    @usuario = User.new
  end

  def edit
    @usuario = User.find(params[:id])
  end

  def create
    @usuario = User.new(usuario_params)
    @usuario.rol = :admin
    @usuario.email_address = "#{@usuario.nombre.parameterize}@stock.local"

    if @usuario.save
      redirect_to gestionar_usuarios_path, notice: "Usuario '#{@usuario.nombre}' creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @usuario = User.find(params[:id])

    if usuario_params[:password].blank?
      params[:user].delete(:password) if params[:user]
      params[:user].delete(:password_confirmation) if params[:user]
    end

    if @usuario.update(usuario_params)
      redirect_to gestionar_usuarios_path, notice: "Usuario '#{@usuario.nombre}' actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @usuario = User.find(params[:id])

    if @usuario.email_address == ENV.fetch("ADMIN_EMAIL", "admin@stockcontrol.com")
      return redirect_to(gestionar_usuarios_path, alert: "No se puede eliminar el administrador principal.")
    end

    if @usuario.visitante?
      return redirect_to(gestionar_usuarios_path, alert: "No se puede eliminar el usuario visitante.")
    end

    @usuario.destroy
    redirect_to gestionar_usuarios_path, notice: "Usuario '#{@usuario.nombre}' eliminado."
  end

  def switch
    user = User.find(params[:id])
    return head :forbidden unless current_user&.admin? || current_user.visitante?

    if current_user.visitante?
      unless user.authenticate(params[:password])
        render json: { success: false, error: "Contraseña incorrecta" }, status: :unauthorized
        return
      end
    end

    terminate_session
    start_new_session_for(user)

    if request.format.json?
      render json: { success: true, user: { id: user.id, nombre: user.nombre, rol: user.rol } }
    else
      redirect_back fallback_location: productos_path, notice: "Sesión cambiada a #{user.nombre}."
    end
  rescue => e
    Rails.logger.error "Error in switch: #{e.message}"
    render json: { success: false, error: e.message }, status: :internal_server_error
  end

  def switch_to_admin
    unless params[:admin_password] == ENV["ADMIN_SWITCH_PASSWORD"]
      render json: { success: false, error: "Contraseña incorrecta" }, status: :unauthorized
      return
    end

    admin_user = User.find_by(rol: :admin)
    unless admin_user
      render json: { success: false, error: "No hay usuario administrador" }, status: :not_found
      return
    end

    terminate_session
    start_new_session_for(admin_user)
    render json: { success: true }
  end

  def switch_with_password
    user = User.find(params[:user_id])
    unless user
      render json: { success: false, error: "Usuario no encontrado" }, status: :not_found
      return
    end

    unless user.authenticate(params[:password])
      render json: { success: false, error: "Contraseña incorrecta" }, status: :unauthorized
      return
    end

    terminate_session
    start_new_session_for(user)
    render json: { success: true }
  end

  def verify_admin
    if params[:admin_password] == ENV["ADMIN_SWITCH_PASSWORD"]
      render json: { success: true }
    else
      render json: { success: false, error: "Contraseña incorrecta" }, status: :unauthorized
    end
  end

  def verify_password
    user = User.find(params[:user_id])
    if user.authenticate(params[:password])
      render json: { success: true }
    else
      render json: { success: false, error: "Contraseña incorrecta" }, status: :unauthorized
    end
  end

  private

  def require_admin
    unless current_user&.admin?
      redirect_to productos_path, alert: "No tienes permiso para realizar esta acción."
    end
  end

  def usuario_params
    params.require(:user).permit(:nombre, :password, :password_confirmation)
  end
end

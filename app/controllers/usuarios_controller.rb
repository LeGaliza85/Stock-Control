class UsuariosController < ApplicationController
  skip_before_action :require_authentication, only: [:index, :new, :gestionar]
  skip_before_action :verify_authenticity_token, only: [], raise: false

  def index
    redirect_to gestionar_usuarios_path
  end

  def gestionar
    @usuarios = User.order(:nombre)
    resume_session
    @current_user = Current.user || User.first
    
    render "index"
  end

  def new
    session_id = cookies.signed[:session_id]
    return redirect_to(new_session_path, alert: "Debes iniciar sesión.") unless session_id
    
    @session = Session.find_by(id: session_id)
    return redirect_to(new_session_path, alert: "Debes iniciar sesión.") unless @session
    
    @current_user = @session.user
    return redirect_to(productos_path, alert: "No tienes permiso.") unless @current_user.admin?
    
    @usuario = User.new
  end

  def edit
    session_id = cookies.signed[:session_id]
    return redirect_to(new_session_path, alert: "Debes iniciar sesión.") unless session_id
    
    @session = Session.find_by(id: session_id)
    return redirect_to(new_session_path, alert: "Debes iniciar sesión.") unless @session
    
    current_user = @session.user
    return redirect_to(gestionar_usuarios_path, alert: "No tienes permiso.") unless current_user && !current_user.visitante?
    
    @usuario = User.find(params[:id])
    @current_user = current_user
  end

  def create
    session_id = cookies.signed[:session_id]
    return redirect_to(new_session_path, alert: "Debes iniciar sesión.") unless session_id
    
    @session = Session.find_by(id: session_id)
    return redirect_to(new_session_path, alert: "Debes iniciar sesión.") unless @session
    
    current_user = @session.user
    return redirect_to(gestionar_usuarios_path, alert: "No tienes permiso.") unless current_user && !current_user.visitante?

    @current_user = current_user
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
    session_id = cookies.signed[:session_id]
    return redirect_to(new_session_path, alert: "Debes iniciar sesión.") unless session_id
    
    @session = Session.find_by(id: session_id)
    return redirect_to(new_session_path, alert: "Debes iniciar sesión.") unless @session
    
    current_user = @session.user
    return redirect_to(gestionar_usuarios_path, alert: "No tienes permiso.") unless current_user && !current_user.visitante?
    
    @current_user = current_user
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
    session_id = cookies.signed[:session_id]
    return redirect_to(new_session_path, alert: "Debes iniciar sesión.") unless session_id
    
    @session = Session.find_by(id: session_id)
    return redirect_to(new_session_path, alert: "Debes iniciar sesión.") unless @session
    
    current_user = @session.user
    return redirect_to(gestionar_usuarios_path, alert: "No tienes permiso.") unless current_user && !current_user.visitante?

    @usuario = User.find(params[:id])

    if @usuario.email_address == "admin@stockcontrol.com"
      redirect_to gestionar_usuarios_path, alert: "No se puede eliminar el administrador principal."
      return
    end

    if @usuario.visitante?
      redirect_to gestionar_usuarios_path, alert: "No se puede eliminar el usuario visitante."
      return
    end

    @usuario.destroy
    redirect_to gestionar_usuarios_path, notice: "Usuario '#{@usuario.nombre}' eliminado."
  end

  def switch
    user = User.find(params[:id])

    terminate_session
    start_new_session_for(user)

    respond_to do |format|
      format.html { redirect_back fallback_location: productos_path, notice: "Sesión cambiada a #{user.nombre}." }
      format.json { render json: { success: true, user: { id: user.id, nombre: user.nombre, rol: user.rol } } }
    end
  end

  def switch_to_admin
    unless params[:admin_password] == "Admin123"
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
    unless params[:admin_password] == "Admin123"
      render json: { success: false, error: "Contraseña incorrecta" }, status: :unauthorized
      return
    end

    user = User.find(params[:user_id])
    unless user
      render json: { success: false, error: "Usuario no encontrado" }, status: :not_found
      return
    end

    terminate_session
    start_new_session_for(user)
    render json: { success: true }
  end

  def verify_admin
    if params[:admin_password] == "Admin123"
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

  def find_user_from_cookie
    return nil unless cookies.signed[:session_id]
    session = Session.find_by(id: cookies.signed[:session_id])
    session&.user
  end

  def usuario_params
    params.require(:user).permit(:nombre, :password, :password_confirmation)
  end

  def require_admin
    unless current_user&.admin?
      redirect_to productos_path, alert: "No tienes permiso para realizar esta acción"
    end
  end

  def terminate_session
    Current.session.destroy if Current.session
    cookies.delete(:session_id)
  end

  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session
      cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
    end
  end
end

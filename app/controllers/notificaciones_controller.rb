class NotificacionesController < ApplicationController
  before_action :require_authentication

  def marcar_leida
    @notificacion = Notificacion.find(params[:id])
    if @notificacion.user_id == current_user.id
      @notificacion.marcar_como_leida!
    end
    redirect_to producto_path(@notificacion.producto)
  end

  def marcar_todas_leidas
    current_user.notificaciones.no_leidas.each do |n|
      n.marcar_como_leida!
    end
    redirect_to request.referer || productos_path
  end

  def eliminar_todas
    current_user.notificaciones.destroy_all
    redirect_to request.referer || productos_path, notice: "Notificaciones eliminadas."
  end

  def eliminar_leidas
    current_user.notificaciones.leidas.destroy_all
    redirect_to request.referer || productos_path, notice: "Notificaciones leídas eliminadas."
  end
end

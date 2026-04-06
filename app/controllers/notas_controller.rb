class NotasController < ApplicationController
  allow_unauthenticated_access only: []
  before_action :require_no_visitante
  before_action :set_producto
  before_action :set_nota, only: [:update, :destroy]
  before_action :authorize_nota!, only: [:update, :destroy]



  def create
    @nota = @producto.notas.build(nota_params)
    @nota.user = current_user

    if @nota.save
      redirect_to @producto, notice: "Nota añadida correctamente."
    else
      redirect_to @producto, alert: "Error al guardar la nota."
    end
  end

  def update
    if current_user.admin? || @nota.user_id == current_user.id
      if @nota.update(nota_params)
        redirect_to @producto, notice: "Nota actualizada correctamente."
      else
        redirect_to @producto, alert: "Error al actualizar la nota."
      end
    else
      redirect_to @producto, alert: "No tienes permiso para editar esta nota."
    end
  end

  def destroy
    @nota.destroy
    redirect_to @producto, notice: "Nota eliminada correctamente."
  end

  private

  def set_producto
    @producto = Producto.find(params[:producto_id])
  end

  def set_nota
    @nota = @producto.notas.find(params[:id])
  end

  def authorize_nota!
    unless current_user.admin? || @nota.user_id == current_user.id
      redirect_to @producto, alert: "No tienes permiso para editar esta nota."
    end
  end

  def nota_params
    params.require(:nota).permit(:contenido)
  end
end

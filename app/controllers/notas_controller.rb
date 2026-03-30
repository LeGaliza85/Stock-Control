class NotasController < ApplicationController
  allow_unauthenticated_access only: []
  before_action :require_no_visitante
  before_action :set_producto

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
    @nota = @producto.notas.find(params[:id])

    if @nota.update(nota_params)
      redirect_to @producto, notice: "Nota actualizada correctamente."
    else
      redirect_to @producto, alert: "Error al actualizar la nota."
    end
  end

  def destroy
    @nota = @producto.notas.find(params[:id])
    @nota.destroy
    redirect_to @producto, notice: "Nota eliminada correctamente."
  end

  private

  def set_producto
    @producto = Producto.find(params[:producto_id])
  end

  def nota_params
    params.permit(:contenido)
  end
end

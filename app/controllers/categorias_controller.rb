class CategoriasController < ApplicationController
  before_action :set_categoria, only: [ :edit, :update, :destroy ]

  def index
    @categorias = Categoria.left_joins(:productos)
                           .select("categorias.*, COUNT(productos.id) as productos_count")
                           .group("categorias.id")
                           .order(:nombre)
  end

  def new
    @categoria = Categoria.new
  end

  def create
    @categoria = Categoria.new(categoria_params)

    if @categoria.save
      redirect_to categorias_path, notice: "Categoría creada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @categoria.update(categoria_params)
      redirect_to categorias_path, notice: "Categoría actualizada exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @categoria.productos.any?
      redirect_to categorias_path, alert: "No se puede eliminar esta categoría porque tiene productos asociados."
    else
      @categoria.destroy
      redirect_to categorias_path, notice: "Categoría eliminada exitosamente."
    end
  end

  private

  def set_categoria
    @categoria = Categoria.find(params[:id])
  end

  def categoria_params
    params.expect(categoria: [ :nombre ])
  end
end

class ProductosController < ApplicationController
  before_action :set_producto, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_owner!, only: [ :edit, :update, :destroy ]

  def index
    @productos = Producto.includes(:user, :categoria).with_attached_fotos.order(created_at: :desc)
    @productos = @productos.buscar(params[:q]) if params[:q].present?
    @productos = @productos.por_categoria(params[:categoria]) if params[:categoria].present?
    @productos = @productos.por_estado(params[:estado]) if params[:estado].present?

    @per_page = (params[:per_page] || 12).to_i
    @per_page = 12 unless [ 12, 24, 48 ].include?(@per_page)
    @page = [ params[:page].to_i, 1 ].max
    @total = @productos.count
    @productos = @productos.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def show
  end

  def new
    @producto = current_user.productos.build
  end

  def create
    @producto = current_user.productos.build(producto_params)

    if @producto.save
      redirect_to @producto, notice: "Producto creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @producto.update(producto_params)
      redirect_to @producto, notice: "Producto actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @producto.destroy
    redirect_to productos_path, notice: "Producto eliminado exitosamente."
  end

  def suggestions
    q = params[:q].to_s.strip
    if q.length < 2
      render json: []
      return
    end

    pattern = "%#{q}%"
    nombres = Producto.where("nombre LIKE ?", pattern).limit(5).pluck(:nombre)
    categorias = Categoria.where("nombre LIKE ?", pattern).limit(3).pluck(:nombre)
    render json: (nombres + categorias).uniq.first(8)
  end

  private

  def set_producto
    @producto = Producto.find(params[:id])
  end

  def authorize_owner!
    unless current_user.admin? || @producto.user_id == current_user.id
      redirect_to productos_path, alert: "No tienes permiso para realizar esta acción"
    end
  end

  def producto_params
    params.expect(producto: [ :nombre, :descripcion, :precio_compra, :precio_venta, :estado, :categoria_id, fotos: [] ])
  end

  def current_user
    Current.user
  end
  helper_method :current_user
end

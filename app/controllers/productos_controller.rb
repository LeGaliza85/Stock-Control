class ProductosController < ApplicationController
  before_action :set_producto, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_owner!, only: [ :edit, :update, :destroy ]
  before_action :require_no_visitante, only: [ :new, :create, :edit, :update, :destroy ]

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
    @categorias_para_filtro = Categoria.order(:nombre).pluck(:nombre, :id)
  end

  def show
  end

  def new
    @producto = current_user.productos.build
    @quick_analyze = params[:quick_analyze] == "1"

    if params[:from_ia] == "1"
      @producto.nombre = params[:nombre] if params[:nombre].present?
      @producto.descripcion = params[:descripcion] if params[:descripcion].present?
      @producto.estado = params[:estado] if params[:estado].present?
    end
  end

  def create
    fotos_nuevas = params[:producto]&.delete(:fotos)
    ia_image_data = params[:producto]&.delete(:ia_image_data)

    Rails.logger.warn "=== CREATE PRODUCT DEBUG ==="
    Rails.logger.warn "ia_image_data present: #{ia_image_data.present?}"
    Rails.logger.warn "ia_image_data starts with data:image: #{ia_image_data&.start_with?("data:image")}"
    Rails.logger.warn "ia_image_data length: #{ia_image_data&.length || 0}"
    Rails.logger.warn "fotos_nuevas present: #{fotos_nuevas.present?}"
    Rails.logger.warn "==========================="

    @producto = current_user.productos.build(producto_params)

    if ia_image_data.present? && ia_image_data.start_with?("data:image")
      begin
        image_data = ia_image_data.sub(/^data:image\/\w+;base64,/, "")
        image_binary = Base64.decode64(image_data)
        filename = "ia_analisis_#{Time.now.to_i}.jpg"
        @producto.fotos.attach(
          io: StringIO.new(image_binary),
          filename: filename,
          content_type: "image/jpeg"
        )
        Rails.logger.warn "IA image attached, fotos count: #{@producto.fotos.count}"
      rescue => e
        Rails.logger.error "Error al procesar imagen IA: #{e.message}"
        Rails.logger.error e.backtrace.first(5).join("\n")
      end
    else
      Rails.logger.warn "IA image NOT attached - ia_image_data: #{ia_image_data.nil? ? 'nil' : 'empty or wrong format'}"
    end

    if @producto.save
      if fotos_nuevas.present?
        fotos_nuevas.each { |foto| @producto.fotos.attach(foto) }
      end
      redirect_to @producto, notice: "Producto creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    fotos_a_eliminar = params[:producto]&.delete(:fotos_a_eliminar) || []
    fotos_nuevas = params[:producto]&.delete(:fotos)

    @producto.last_updated_by_id = current_user.id

    if @producto.update(producto_params)
      fotos_a_eliminar.each do |foto_id|
        @producto.fotos.find(foto_id.to_i)&.purge_later
      end

      if fotos_nuevas.present?
        fotos_nuevas.each { |foto| @producto.fotos.attach(foto) }
      end

      redirect_to @producto, notice: "Producto actualizado exitosamente."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @producto.destroy
    respond_to do |format|
      format.html { redirect_to productos_path, notice: "Producto eliminado exitosamente." }
      format.json { render json: { success: true, redirect: productos_path } }
    end
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

  def require_no_visitante
    if current_user.visitante?
      redirect_to productos_path, alert: "No tienes permiso para realizar esta acción"
    end
  end

  def producto_params
    params.expect(producto: [ :nombre, :descripcion, :precio_compra, :precio_venta, :estado, :categoria_id, :etiqueta, :ia_image_data ])
  end
end

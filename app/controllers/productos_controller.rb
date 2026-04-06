class ProductosController < ApplicationController
  before_action :set_producto, only: [ :show, :edit, :update, :destroy, :fotos_json ]
  before_action :require_no_visitante, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :authorize_owner!, only: [ :edit, :update, :destroy ]

  def index
    @productos = filtered_productos
    @categorias_para_filtro = Categoria.order(:nombre).pluck(:nombre, :id)
  end

  def show
    if authenticated? && !current_user.visitante?
      ProductoVisto.registrar!(@producto, current_user)
      current_user.notificaciones.where(producto: @producto, leida: false).update_all(leida: true)
    end
  end

  def fotos_json
    fotos = @producto.fotos.attached? ? @producto.fotos.map { |f| url_for(f) } : []
    render json: { fotos: fotos }
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
    @producto = current_user.productos.build(producto_params)
    attach_ia_image

    if @producto.save
      crear_notificaciones_nuevo_producto(@producto)
      redirect_to @producto, notice: "Producto creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @producto.last_updated_by_id = current_user.id

    unless @producto.update(producto_params)
      render :edit, status: :unprocessable_entity
      return
    end

    eliminar_fotos_marcadas
    agregar_fotos_nuevas
    redirect_to @producto, notice: "Producto actualizado exitosamente."
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

  def buscar_por_imagen
    image_data = extract_image_data

    unless image_data.present?
      @error = "Se requiere una imagen"
      respond_to do |format|
        format.turbo_stream
        format.json { render json: { error: @error }, status: :bad_request }
      end
      return
    end

    service = ProductoBusquedaService.new(current_user)
    result = service.buscar_por_imagen(image_data)

    if result[:error]
      @error = result[:error]
    else
      @productos = result[:productos].map { |item| { producto: item[:producto], similitud: item[:score].round } }
    end

    respond_to do |format|
      format.turbo_stream
      format.json do
        if @error
          render json: { error: @error }, status: :internal_server_error
        else
          render json: {
            analisis: result[:analisis],
            productos: result[:productos].map { |item| producto_json(item[:producto], item[:score].round) },
            metodo: result[:metodo]
          }
        end
      end
    end
  end

  private

  def set_producto
    @producto = Producto.includes(:user, :categoria).with_attached_fotos.find(params[:id])
  end

  def authorize_owner!
    unless current_user.admin? || @producto.user_id == current_user.id
      redirect_to productos_path, alert: "No tienes permiso para realizar esta acción."
    end
  end

  def filtered_productos
    @per_page = (params[:per_page] || 12).to_i
    @per_page = 12 unless [ 12, 24, 48 ].include?(@per_page)
    @page = [ params[:page].to_i, 1 ].max

    base = if params[:vistos] == "true" && authenticated? && !current_user.visitante?
      ids = ProductoVisto.where(user: current_user).order(visto_at: :desc).pluck(:producto_id)
      if ids.empty?
        Producto.none
      else
        order_clause = ids.each_with_index.map { |id, i| "WHEN #{ActiveRecord::Base.connection.quote(id)} THEN #{i}" }.join(" ")
        Producto.includes(:user, :categoria).with_attached_fotos.where(id: ids).order(Arel.sql("CASE id #{order_clause} END"))
      end
    else
      Producto.includes(:user, :categoria).with_attached_fotos.order(created_at: :desc)
    end

    base = base.buscar(params[:q]) if params[:q].present?
    base = base.por_categoria(params[:categoria]) if params[:categoria].present?
    base = base.por_estado(params[:estado]) if params[:estado].present?
    base = base.por_etiqueta(params[:etiqueta]) if params[:etiqueta].present?

    @total = base.count
    base.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def attach_ia_image
    ia_image_data = params.dig(:producto, :ia_image_data)
    return unless ia_image_data.present? && ia_image_data.start_with?("data:image")

    image_binary = Base64.decode64(ia_image_data.sub(/^data:image\/\w+;base64,/, ""))
    @producto.fotos.attach(
      io: StringIO.new(image_binary),
      filename: "ia_analisis_#{Time.now.to_i}.jpg",
      content_type: "image/jpeg"
    )
  rescue => e
    Rails.logger.error "Error attaching IA image: #{e.message}"
  end

  def buscar_productos_similares(analisis)
    tipo = analisis["tipo_producto"] || ""
    palabras_clave = analisis["palabras_clave"] || []

    return [] if tipo.blank? && palabras_clave.empty?

    terminos_busqueda = []
    if tipo.present? && tipo != "No visible"
      terminos_busqueda << tipo.downcase.strip
    end

    if palabras_clave.is_a?(Array) && palabras_clave.any?
      terminos_excluir = [ "no visible", "no detectable", "no perceptible", "no identificado", "no determinado", "ninguna", "ninguno" ]
      palabras_filtradas = palabras_clave.map(&:to_s).map(&:downcase).map(&:strip).reject { |p|
        p.blank? || p.length < 4 || terminos_busqueda.include?(p) || terminos_excluir.include?(p) || p.match?(/^\d+/)
      }
      terminos_busqueda += palabras_filtradas.first(8)
    end

    terminos_busqueda = terminos_busqueda.uniq
    return [] if terminos_busqueda.empty?

    productos = Producto.includes(:user, :categoria, :fotos_attachments)
      .buscar(terminos_busqueda.join(" "))
      .limit(100)

    productos.map { |p| { producto: p, score: calcular_similitud(terminos_busqueda, p) } }
      .select { |r| r[:score] >= 2 }
      .sort_by { |r| -r[:score] }
      .first(15)
      .map { |r| r[:producto] }
  end

  def calcular_similitud(terminos, producto)
    score = 0
    descripcion = producto.descripcion.to_s.downcase
    nombre = producto.nombre.to_s.downcase
    categoria = producto.categoria&.nombre.to_s.downcase

    terminos.each do |termino|
      if nombre.include?(termino)
        score += 10
      elsif descripcion.include?(termino)
        score += 5
      elsif categoria.include?(termino)
        score += 3
      end
    end
    score
  end

  def eliminar_fotos_marcadas
    fotos_raw = params.dig(:producto, :fotos_a_eliminar)
    return unless fotos_raw.present?

    ids = case fotos_raw
    when Array then fotos_raw.reject(&:blank?)
    when String then fotos_raw.split(",").map(&:strip).reject(&:blank?)
    else []
    end

    ids.each do |foto_id|
      @producto.fotos.find_by(id: foto_id.to_i)&.purge
    rescue => e
      Rails.logger.error "Error eliminando foto #{foto_id}: #{e.message}"
    end
  end

  def agregar_fotos_nuevas
    fotos_nuevas = params.dig(:producto, :fotos)
    return unless fotos_nuevas.is_a?(Array)

    fotos_validas = fotos_nuevas.select { |f| f.present? && f.respond_to?(:size) && f.size > 0 }
    @producto.fotos.attach(fotos_validas) if fotos_validas.any?
  rescue => e
    Rails.logger.error "Error adjuntando fotos: #{e.message}"
  end

  def producto_json(producto, similitud = nil)
    data = {
      id: producto.id,
      nombre: producto.nombre,
      descripcion: producto.descripcion,
      precio_venta: producto.precio_venta,
      etiqueta: producto.etiqueta,
      categoria: producto.categoria&.nombre,
      fotos: producto.fotos.attached? ? url_for(producto.fotos.first) : nil
    }
    data[:similitud] = similitud if similitud
    data
  end

  def crear_notificaciones_nuevo_producto(producto)
    User.where(rol: :admin).where.not(id: current_user.id).each do |admin|
      Notificacion.find_or_create_by!(user: admin, producto: producto) do |n|
        n.tipo = "nuevo_producto"
        n.leida = false
      end
    end
  end

    def extract_image_data
    imagen = [params[:imagen], params[:imagen_galeria], params[:imagen_camara]].compact.find do |f|
      f.is_a?(String) ? f.present? : (f.respond_to?(:size) && f.size > 0)
    end
    
    return imagen if imagen.is_a?(String) && imagen.present?
    return nil unless imagen.respond_to?(:read)

    content_type = imagen.respond_to?(:content_type) ? (imagen.content_type || "image/jpeg") : "image/jpeg"
    encoded = Base64.strict_encode64(imagen.read)
    "data:#{content_type};base64,#{encoded}"
  end

  def producto_params
    params.expect(producto: [ :nombre, :descripcion, :precio_compra, :precio_venta, :estado, :categoria_id, :etiqueta, fotos: [] ])
  end
end

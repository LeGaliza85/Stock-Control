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

  def fotos_json
    @producto = Producto.find(params[:id])
    fotos = []
    if @producto.fotos.attached?
      fotos = @producto.fotos.map { |f| url_for(f) }
    end
    render json: { fotos: fotos }
  end

  def new
    @producto = current_user.productos.build
    @quick_analyze = params[:quick_analyze] == "1"

    if params[:from_ia] == "1"
      if params[:nombre].present?
        @producto.nombre = params[:nombre]
      elsif params[:ia_tipo_producto].present?
        @producto.nombre = generar_nombre_desde_ia(params[:ia_tipo_producto], params[:ia_palabras_clave])
      elsif params[:ia_palabras_clave].present?
        @producto.nombre = generar_nombre_desde_ia(nil, params[:ia_palabras_clave])
      end
      
      @producto.descripcion = params[:descripcion] if params[:descripcion].present?
      @producto.estado = params[:estado] if params[:estado].present?
    end
  end

  def generar_nombre_desde_ia(tipo_producto, palabras_clave_json = nil, descripcion = nil)
    partes = []
    
    tipos_genericos = ['no identificable', 'genérico', 'utensilio del hogar', 'objeto', 'producto', 'artículo']
    tipo_limpio = tipo_producto.to_s.strip.downcase
    
    if tipo_producto.present? && tipo_producto.to_s.strip.length > 2 && !tipos_genericos.any? { |t| tipo_limpio.include?(t) }
      partes << tipo_producto.to_s.strip
    end
    
    if palabras_clave_json.present?
      begin
        palabras = JSON.parse(palabras_clave_json)
        excluir = ['no visible', 'no detectable', 'no perceptible', 'no identificado', 'no determinado', 'ninguna', 'ninguno']
        
        palabras_filtradas = palabras.select { |p| 
          p.to_s.length > 3 && 
          !excluir.include?(p.to_s.downcase) && 
          p.to_s !~ /^\d+$/ &&
          !tipo_producto.to_s.downcase.include?(p.to_s.downcase)
        }.first(3)
        
        partes.concat(palabras_filtradas)
      rescue
      end
    end
    
    if partes.empty? && descripcion.present?
      primeras_palabras = descripcion.to_s.split.first(5).join(' ')
      partes << primeras_palabras if primeras_palabras.length > 3
    end
    
    nombre = partes.join(' - ')
    nombre.blank? ? 'Producto sin nombre' : (nombre.length > 50 ? nombre[0..46] + '...' : nombre)
  end

  def create
    ia_image_data = params[:producto]&.delete(:ia_image_data)

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
      rescue => e
        Rails.logger.error "Error al procesar imagen IA: #{e.message}"
      end
    end

    if @producto.save
      redirect_to @producto, notice: "Producto creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # Obtener fotos a eliminar y fotos nuevas
    fotos_raw = params[:producto][:fotos_a_eliminar] if params[:producto].present?
    fotos_nuevas = params[:producto][:fotos] if params[:producto].present?
    
    Rails.logger.warn "=== UPDATE DEBUG ==="
    Rails.logger.warn "fotos_nuevas type: #{fotos_nuevas.class}"
    if fotos_nuevas.is_a?(Array)
      Rails.logger.warn "fotos_nuevas count: #{fotos_nuevas.count}"
      fotos_nuevas.each_with_index do |f, i|
        Rails.logger.warn "  foto[#{i}]: #{f.class} - empty: #{f.blank?} - size: #{f.respond_to?(:size) ? f.size : 'N/A'}"
      end
    end
    Rails.logger.warn "====================="
    
    @producto.last_updated_by_id = current_user.id

    # Primero actualizar los campos sin tocar las fotos
    producto_params_hash = params.require(:producto).permit(:nombre, :descripcion, :precio_compra, :precio_venta, :estado, :categoria_id, :etiqueta, :ia_image_data)
    
    if !@producto.update(producto_params_hash)
      render :edit, status: :unprocessable_entity
      return
    end
    
    # Eliminar fotos marcadas
    fotos_raw = params[:producto][:fotos_a_eliminar] if params[:producto].present?
    
    # Procesar los IDs de fotos a eliminar
    fotos_ids = []
    if fotos_raw.is_a?(Array)
      fotos_ids = fotos_raw.reject { |v| v.blank? }
    elsif fotos_raw.is_a?(String) && fotos_raw.present?
      fotos_ids = fotos_raw.split(',').map(&:strip).reject(&:blank?)
    end
    
    fotos_ids.each do |foto_id|
      foto_id = foto_id.to_s.strip
      next if foto_id.blank?
      begin
        foto = @producto.fotos.find(foto_id.to_i)
        foto.purge if foto
      rescue => e
        Rails.logger.error "Error eliminando foto #{foto_id}: #{e.message}"
      end
    end

    # Agregar fotos nuevas SIN eliminar las existentes
    if fotos_nuevas.present? && fotos_nuevas.is_a?(Array)
      fotos_validas = fotos_nuevas.select do |foto|
        foto.present? && foto.respond_to?(:size) && foto.size > 0
      end
      
      if fotos_validas.any?
        begin
          @producto.fotos.attach(fotos_validas)
        rescue => e
          Rails.logger.error "Error adjuntando fotos: #{e.message}"
        end
      end
    end

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
    image_data = params[:imagen]

    if image_data.nil? || image_data.empty?
      render json: { error: "Se requiere una imagen" }, status: :bad_request
      return
    end

    analyzer = ImageAnalyzerService.new(current_user)

    begin
      embedding_json = analyzer.get_embedding_from_image(image_data)
      
      if embedding_json.nil?
        result = analyzer.analize_para_busqueda(image_data)

        if result[:error]
          render json: result, status: :unprocessable_entity
          return
        end

        resultados = buscar_productos_similares(result)
        producto = resultados.first
        
        render json: {
          analisis: result,
          producto: producto ? {
            id: producto.id,
            nombre: producto.nombre,
            descripcion: producto.descripcion,
            precio_venta: producto.precio_venta,
            etiqueta: producto.etiqueta,
            categoria: producto.categoria&.nombre,
            fotos: producto.fotos.attached? ? url_for(producto.fotos.first) : nil
          } : nil,
          metodo: "legacy"
        }
        return
      end

      resultado = Producto.buscar_por_embedding(embedding_json, limit: 1).first

      render json: {
        analisis: { descripcion: "Búsqueda por similitud visual" },
        producto: resultado ? {
          id: resultado.id,
          nombre: resultado.nombre,
          descripcion: resultado.descripcion,
          precio_venta: resultado.precio_venta,
          etiqueta: resultado.etiqueta,
          categoria: resultado.categoria&.nombre,
          fotos: resultado.fotos.attached? ? url_for(resultado.fotos.first) : nil
        } : nil,
        metodo: "clip"
      }
    rescue => e
      Rails.logger.error "Error en buscar_por_imagen: #{e.message}"
      render json: { error: "Error al analizar imagen: #{e.message}" }, status: :internal_server_error
    end
  end

  private

  def buscar_productos_similares(analisis)
    tipo = analisis["tipo_producto"] || ""
    palabras_clave = analisis["palabras_clave"] || []
    
    return [] if tipo.blank? && palabras_clave.empty?

    terminos_busqueda = []
    
    if tipo.present? && tipo != "No visible"
      terminos_busqueda << tipo.downcase.strip
    end
    
    if palabras_clave.is_a?(Array) && palabras_clave.any?
      terminos_excluir = ["no visible", "no detectable", "no perceptible", "no identificado", "no determinado", "ninguna", "ninguno"]
      palabras_filtradas = palabras_clave.map(&:to_s).map(&:downcase).map(&:strip).reject { |p| 
        p.blank? || p.length < 4 || terminos_busqueda.include?(p) || terminos_excluir.include?(p) || p.match?(/^\d+/)
      }
      terminos_busqueda += palabras_filtradas.first(8)
    end
    
    terminos_busqueda = terminos_busqueda.uniq
    return [] if terminos_busqueda.empty?
    
    Rails.logger.warn "=== TERMINOS DE BUSQUEDA: #{terminos_busqueda.inspect} ==="

    productos = Producto.includes(:user, :categoria, :fotos_attachments)
      .buscar(terminos_busqueda.join(" "))
      .limit(100)
    
    Rails.logger.warn "=== PRODUCTOS ENCONTRADOS: #{productos.count} ==="
    
    resultados_con_score = productos.map do |p|
      score = calcular_similitud(terminos_busqueda, p)
      { producto: p, score: score }
    end
    
    resultados_ordenados = resultados_con_score
      .select { |r| r[:score] >= 2 }
      .sort_by { |r| -r[:score] }
      .first(15)
    
    Rails.logger.warn "=== RESULTADOS FINALES: #{resultados_ordenados.count} ==="
    
    resultados_ordenados.map { |r| r[:producto] }
  end

  def calcular_similitud(terminos, producto)
    score = 0
    descripcion_producto = producto.descripcion.to_s.downcase
    nombre_producto = producto.nombre.to_s.downcase
    categoria_nombre = producto.categoria&.nombre.to_s.downcase
    
    terminos.each do |termino|
      coincidencia_nombre = nombre_producto.include?(termino)
      coincidencia_desc = descripcion_producto.include?(termino)
      coincidencia_cat = categoria_nombre.include?(termino)
      
      if coincidencia_nombre
        score += 10
      elsif coincidencia_desc
        score += 5
      elsif coincidencia_cat
        score += 3
      end
    end
    
    score
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
    params.expect(producto: [ :nombre, :descripcion, :precio_compra, :precio_venta, :estado, :categoria_id, :etiqueta, :ia_image_data, :fotos => [] ])
  end
end

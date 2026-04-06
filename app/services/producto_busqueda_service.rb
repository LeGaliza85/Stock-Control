class ProductoBusquedaService
  EXCLUDE_KEYWORDS = [
    "no visible", "no detectable", "no perceptible",
    "no identificado", "no determinado", "ninguna", "ninguno"
  ].freeze

  def initialize(user)
    @user = user
  end

  def buscar_por_imagen(image_data)
    analyzer = ImageAnalyzerService.new(@user)
    embedding_json = analyzer.get_embedding_from_image(image_data)

    if embedding_json.present?
      buscar_con_clip(embedding_json)
    else
      buscar_con_legacy(analyzer, image_data)
    end
  rescue => e
    { error: "Error al analizar imagen: #{e.message}" }
  end

  private

  def buscar_con_clip(embedding_json)
    resultados = Producto.buscar_por_embedding(embedding_json, limit: 5)
    {
      analisis: { "descripcion" => "Búsqueda por similitud visual" },
      productos: resultados,
      metodo: "clip"
    }
  end

  def buscar_con_legacy(analyzer, image_data)
    result = analyzer.analize_para_busqueda(image_data)
    return { error: result[:error], metodo: "legacy" } if result[:error]

    productos = buscar_productos_similares(result)
    {
      analisis: result,
      productos: productos,
      metodo: "legacy"
    }
  end

  def buscar_productos_similares(analisis)
    tipo = analisis["tipo_producto"] || ""
    palabras_clave = analisis["palabras_clave"] || []

    return [] if tipo.blank? && palabras_clave.empty?

    terminos_busqueda = build_terminos(tipo, palabras_clave)
    return [] if terminos_busqueda.empty?

    Producto.includes(:user, :categoria, :fotos_attachments)
      .buscar(terminos_busqueda.join(" "))
      .limit(100)
      .map { |p| { producto: p, score: calcular_similitud(terminos_busqueda, p) } }
      .select { |r| r[:score] >= 2 }
      .sort_by { |r| -r[:score] }
      .first(15)
      .map { |r| r[:producto] }
  end

  def build_terminos(tipo, palabras_clave)
    terminos = []

    if tipo.present? && tipo != "No visible"
      terminos << tipo.downcase.strip
    end

    if palabras_clave.is_a?(Array) && palabras_clave.any?
      filtradas = palabras_clave.map(&:to_s).map(&:downcase).map(&:strip).reject { |p|
        p.blank? || p.length < 4 || terminos.include?(p) || EXCLUDE_KEYWORDS.include?(p) || p.match?(/^\d+/)
      }
      terminos += filtradas.first(8)
    end

    terminos.uniq
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
end

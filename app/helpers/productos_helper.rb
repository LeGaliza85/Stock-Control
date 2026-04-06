module ProductosHelper
  ETIQUETA_COLORS = {
    "en_venta" => "bg-gradient-to-r from-green-500 to-emerald-500",
    "reservado" => "bg-gradient-to-r from-amber-500 to-orange-500",
    "vendido" => "bg-gradient-to-r from-red-500 to-rose-500",
    "en_restauracion" => "bg-gradient-to-r from-violet-500 to-purple-500"
  }.freeze

  ETIQUETA_TEXTOS = {
    "en_venta" => "EN VENTA",
    "reservado" => "RESERVADO",
    "vendido" => "VENDIDO",
    "en_restauracion" => "EN RESTAURACIÓN"
  }.freeze

  ESTADO_COLORS = {
    "nuevo" => "bg-[#E8F0E8] text-[#3D5E3D]",
    "bueno" => "bg-[#E4ECF4] text-[#3D5470]",
    "aceptable" => "bg-[#F5ECD7] text-[#8B6914]",
    "desgastado" => "bg-[#F4E4DC] text-[#8B4F3A]",
    "para_restaurar" => "bg-[#F4DCDC] text-[#7F3333]"
  }.freeze

  EXCLUDE_KEYWORDS = [
    "no identificable", "genérico", "utensilio del hogar",
    "objeto", "producto", "artículo"
  ].freeze

  EXCLUDE_PALABRAS = [
    "no visible", "no detectable", "no perceptible",
    "no identificado", "no determinado", "ninguna", "ninguno"
  ].freeze

  def etiqueta_badge(etiqueta, size: "text-[10px]")
    color = ETIQUETA_COLORS[etiqueta] || "bg-gray-500"
    texto = ETIQUETA_TEXTOS[etiqueta] || etiqueta.to_s.humanize
    tag.div texto, class: "#{size} font-bold text-center py-0.5 #{color} text-white"
  end

  def estado_badge(estado)
    color = ESTADO_COLORS[estado] || "bg-gray-100 text-gray-600"
    tag.span estado.to_s.humanize, class: "inline-flex items-center rounded-full px-2.5 py-1 text-xs font-medium #{color}"
  end

  def generar_nombre_ia(tipo_producto, palabras_clave_json = nil, descripcion = nil)
    partes = []
    tipo_limpio = tipo_producto.to_s.strip.downcase

    if tipo_producto.present? && tipo_producto.to_s.strip.length > 2 && EXCLUDE_KEYWORDS.none? { |t| tipo_limpio.include?(t) }
      partes << tipo_producto.to_s.strip
    end

    if palabras_clave_json.present?
      begin
        palabras = JSON.parse(palabras_clave_json)
        filtradas = palabras.select { |p|
          p.to_s.length > 3 &&
          EXCLUDE_PALABRAS.exclude?(p.to_s.downcase) &&
          p.to_s !~ /^\d+$/ &&
          !tipo_producto.to_s.downcase.include?(p.to_s.downcase)
        }.first(3)
        partes.concat(filtradas)
      rescue
      end
    end

    if partes.empty? && descripcion.present?
      primeras = descripcion.to_s.split.first(5).join(" ")
      partes << primeras if primeras.length > 3
    end

    nombre = partes.join(" - ")
    nombre.blank? ? "Producto sin nombre" : nombre.truncate(50, omission: "...")
  end
end

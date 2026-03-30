require 'base64'

class Producto < ApplicationRecord
  belongs_to :user
  belongs_to :last_updated_by, class_name: "User", optional: true
  belongs_to :categoria
  has_many_attached :fotos
  has_many :historiales, class_name: "ProductoHistorial", dependent: :destroy
  has_many :notas, dependent: :destroy

  enum :estado, {
    nuevo: 0,
    bueno: 1,
    aceptable: 2,
    desgastado: 3,
    para_restaurar: 4
  }

  enum :etiqueta, {
    en_venta: 0,
    reservado: 1,
    vendido: 2,
    en_restauracion: 3
  }, default: :en_venta

  validates :nombre, :descripcion, :precio_compra, :precio_venta,
            :estado, :categoria_id, :etiqueta, presence: true
  validates :precio_compra, :precio_venta, numericality: { greater_than_or_equal_to: 0 }

  before_create :generar_codigo
  after_save :generar_embedding, if: :fotos_changed_or_missing_embedding?
  after_save :registrar_cambios

  def fotos_changed_or_missing_embedding?
    fotos.attached? && embedding.blank?
  end

  def generar_embedding
    return unless fotos.attached?
    return if embedding.present?

    first_foto = fotos.first
    return unless first_foto
    return unless first_foto.blob

    begin
      blob = first_foto.blob
      image_binary = blob.download
      base64_encoded = Base64.strict_encode64(image_binary)
      image_data = "data:#{blob.content_type};base64,#{base64_encoded}"
      
      analyzer = ImageAnalyzerService.new(user)
      embedding_json = analyzer.get_embedding_from_image(image_data)
      
      if embedding_json
        update_column(:embedding, embedding_json)
      end
    rescue => e
      Rails.logger.error "Error generando embedding: #{e.message}"
    end
  end

  def registrar_cambios
    return if Rails.env.test?
    
    editor = last_updated_by || user
    return unless editor.present?

    if saved_change_to_created_at?
      ProductoHistorial.registrar(self, editor, "creado", nil, "Producto creado", "Producto creado")
      return
    end

    return unless previous_changes.present?

    changes_to_track = {
      "nombre" => :nombre,
      "precio_compra" => :precio_compra,
      "precio_venta" => :precio_venta,
      "estado" => :estado,
      "etiqueta" => :etiqueta,
      "categoria_id" => :categoria_id
    }

    previous_changes.each do |attr, (valor_anterior, valor_nuevo)|
      campo = attr.to_s
      next unless changes_to_track.key?(campo)

      if campo == "categoria_id"
        valor_anterior = Categoria.find_by(id: valor_anterior)&.nombre
        valor_nuevo = Categoria.find_by(id: valor_nuevo)&.nombre
      elsif campo == "estado" || campo == "etiqueta"
        valor_anterior = valor_anterior.to_s if valor_anterior
        valor_nuevo = valor_nuevo.to_s if valor_nuevo
      end

      ProductoHistorial.registrar(self, editor, campo, valor_anterior, valor_nuevo)
    end

    if previous_changes.key?("descripcion")
      ProductoHistorial.registrar(self, editor, "descripcion", "modificada", "modificada", "Descripción modificada")
    end

    if fotos.attached? && previous_changes.key?("fotos")
      ProductoHistorial.registrar(self, editor, "fotos", "cambiadas", "cambiadas", "Fotos actualizadas")
    end
  end

  def self.buscar_por_embedding(embedding_json, limit: 20)
    return [] if embedding_json.blank?

    begin
      query_embedding = JSON.parse(embedding_json)
    rescue
      return []
    end

    productos_with_embedding = where("embedding IS NOT NULL AND embedding != ''")
    
    return [] unless productos_with_embedding.any?

    scored = productos_with_embedding.map do |p|
      begin
        stored_embedding = JSON.parse(p.embedding)
        score = cosine_similarity(query_embedding, stored_embedding)
        { producto: p, score: score }
      rescue
        { producto: p, score: 0 }
      end
    end

    scored.select { |s| s[:score] > 0.8 }
          .sort_by { |s| -s[:score] }
          .first(limit)
          .map { |s| s[:producto] }
  end

  def self.cosine_similarity(a, b)
    return 0 if a.blank? || b.blank?
    return 0 if a.length != b.length

    dot_product = a.each_with_index.sum { |x, i| x * b[i] }
    magnitude_a = Math.sqrt(a.sum { |x| x * x })
    magnitude_b = Math.sqrt(b.sum { |x| x * x })

    return 0 if magnitude_a.zero? || magnitude_b.zero?

    dot_product / (magnitude_a * magnitude_b)
  end

  scope :buscar, ->(termino) {
    return all if termino.blank?
    
    terminos = termino.gsub(/[^a-zA-Z0-9áéíóúñÁÉÍÓÚÑ\s]/, " ")
      .split
      .reject(&:blank?)
      .uniq
      .first(10)
    
    return all if terminos.empty?
    
    conditions = []
    params = {}
    
    terminos.each_with_index do |term, index|
      pattern = "%#{term}%"
      conditions << "(productos.nombre LIKE :p#{index} OR productos.descripcion LIKE :p#{index} OR categorias.nombre LIKE :p#{index} OR productos.codigo LIKE :p#{index})"
      params["p#{index}".to_sym] = pattern
    end
    
    left_joins(:categoria).where(conditions.join(" OR "), params).order("productos.created_at DESC")
  }

  scope :por_categoria, ->(cat) { where(categoria_id: cat) if cat.present? }
  scope :por_estado, ->(est) { where(estado: est) if est.present? }
  scope :por_etiqueta, ->(etiq) { where(etiqueta: etiq) if etiq.present? }

  private

  def generar_codigo
    return if categoria.nil? || categoria.prefijo.blank?

    # Buscar último número para este prefijo
    prefijo = categoria.prefijo
    productos_existentes = Producto.where("codigo LIKE ?", "#{prefijo}%")

    # Extract numeric parts and find max
    max_num = productos_existentes.pluck(:codigo).map do |code|
      code.gsub(prefijo, "").to_i
    end.max || 0

    self.codigo = "#{prefijo}#{max_num + 1}"
  end
end

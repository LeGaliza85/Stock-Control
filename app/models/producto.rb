require 'base64'
require 'tempfile'

class Producto < ApplicationRecord
  include PgSearch::Model

  has_neighbors :embedding, dimensions: 512
  broadcasts_to ->(producto) { "productos" }, inserts_by: :prepend

  belongs_to :user
  belongs_to :last_updated_by, class_name: "User", optional: true
  belongs_to :categoria
  has_many_attached :fotos
  has_many :historiales, class_name: "ProductoHistorial", dependent: :destroy
  has_many :notas, dependent: :destroy
  has_many :notificaciones, class_name: 'Notificacion', foreign_key: 'producto_id', dependent: :destroy

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
  after_commit :queue_embedding_generation, on: [:create, :update]
  after_save :registrar_cambios

  def queue_embedding_generation
    if fotos.attached? && (previous_changes.key?("fotos") || embedding.blank?)
      GenerateEmbeddingJob.perform_later(id)
    end
  end

  def registrar_cambios
    AuditLogService.new(self).call
  end

  def self.buscar_por_embedding(embedding_json, limit: 5)
    SimilaritySearchService.buscar(embedding_json, limit: limit)
  end

  pg_search_scope :pg_search_buscar,
                  against: [ :nombre, :descripcion, :codigo ],
                  associated_against: { categoria: :nombre },
                  ignoring: :accents,
                  using: {
                    tsearch: { any_word: true, prefix: true },
                    trigram: { word_similarity: true }
                  }

  scope :buscar, ->(termino) {
    return all if termino.blank?
    pg_search_buscar(termino)
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

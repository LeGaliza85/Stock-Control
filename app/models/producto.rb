class Producto < ApplicationRecord
  belongs_to :user
  belongs_to :categoria
  has_many_attached :fotos

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

  scope :buscar, ->(termino) {
    return all if termino.blank?
    sanitized = termino.gsub(/[^a-zA-Z0-9áéíóúñÁÉÍÓÚÑ\s]/, "").strip
    return all if sanitized.blank?
    pattern = "%#{sanitized}%"
    left_joins(:categoria).where(
      "productos.nombre LIKE :p OR productos.descripcion LIKE :p OR categorias.nombre LIKE :p",
      p: pattern
    )
  }

  scope :por_categoria, ->(cat) { where(categoria_id: cat) if cat.present? }
  scope :por_estado, ->(est) { where(estado: est) if est.present? }
  scope :por_etiqueta, ->(etiq) { where(etiqueta: etiq) if etiq.present? }
end

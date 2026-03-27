class Categoria < ApplicationRecord
  has_many :productos, dependent: :restrict_with_error

  validates :nombre, presence: true, uniqueness: { case_sensitive: false }
  validates :prefijo, presence: true, uniqueness: true, on: :create

  before_validation :asignar_prefijo, on: :create

  private

  def asignar_prefijo
    return if nombre.blank?

    letra_base = nombre[0].upcase

    # Contar categorías existentes que empiezan con la misma letra
    conflictos = Categoria.where("UPPER(nombre) LIKE ?", "#{letra_base}%").count

    # Prefijo = primeras (conflictos + 1) letras
    letras_necesarias = conflictos + 1
    self.prefijo = nombre[0, letras_necesarias].upcase
  end
end

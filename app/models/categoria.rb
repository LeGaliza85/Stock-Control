class Categoria < ApplicationRecord
  has_many :productos, dependent: :restrict_with_error

  validates :nombre, presence: true, uniqueness: { case_sensitive: false }
end

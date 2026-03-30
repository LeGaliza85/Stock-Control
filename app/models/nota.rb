class Nota < ApplicationRecord
  self.table_name = 'notas'
  
  belongs_to :producto
  belongs_to :user

  validates :contenido, presence: true, length: { maximum: 1000 }

  scope :orden_recientes, -> { order(created_at: :desc) }
end

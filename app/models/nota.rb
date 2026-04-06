class Nota < ApplicationRecord
  self.table_name = 'notas'

  belongs_to :producto
  belongs_to :user

  validates :contenido, :producto_id, :user_id, presence: true
  validates :contenido, length: { maximum: 1000 }

  scope :orden_recientes, -> { order(created_at: :desc) }
end

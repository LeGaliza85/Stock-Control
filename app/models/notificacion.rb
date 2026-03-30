class Notificacion < ApplicationRecord
  self.table_name = 'notificaciones'
  
  belongs_to :user
  belongs_to :producto

  validates :user_id, uniqueness: { scope: :producto_id, message: "ya tiene notificación para este producto" }

  scope :no_leidas, -> { where(leida: false).order(created_at: :desc) }
  scope :leidas, -> { where(leida: true).order(created_at: :desc) }
  scope :recientes, -> { order(created_at: :desc) }

  def marcar_como_leida!
    update!(leida: true)
  end
end

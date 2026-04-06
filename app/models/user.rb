class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :productos, dependent: :destroy
  has_many :ia_usages, dependent: :destroy
  has_many :notificaciones, class_name: 'Notificacion', foreign_key: 'user_id', dependent: :destroy

  enum :rol, { visitante: 0, admin: 2 }

  validates :nombre, presence: true
  validates :password, presence: true, length: { minimum: 4 }, on: :create

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def visitante?
    rol == "visitante"
  end

  def admin?
    rol == "admin"
  end

  def puede_editar?
    !visitante?
  end

  def puede_usar_ia?
    !visitante?
  end
end

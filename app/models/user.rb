class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :productos

  enum :rol, { miembro: 0, admin: 1 }

  validates :nombre, presence: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end

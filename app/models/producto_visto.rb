class ProductoVisto < ApplicationRecord
  belongs_to :producto
  belongs_to :user

  validates :producto_id, :user_id, presence: true

  def self.registrar!(producto, usuario)
    find_or_initialize_by(producto: producto, user: usuario).update!(visto_at: Time.current)
  end

  def self.vistos_recientemente(usuario, limite = 20)
    where(user: usuario)
      .includes(:producto)
      .order(visto_at: :desc)
      .limit(limite)
      .map(&:producto)
  end
end

class ProductoHistorial < ApplicationRecord
  self.table_name = "producto_historiales"

  belongs_to :producto
  belongs_to :user

  def self.registrar(producto, usuario, campo, valor_anterior, valor_nuevo, resumen = nil)
    create!(
      producto: producto,
      user: usuario,
      campo: campo,
      valor_anterior: valor_anterior,
      valor_nuevo: valor_nuevo,
      resumen: resumen || generar_resumen(campo, valor_anterior, valor_nuevo)
    )
  end

  def self.generar_resumen(campo, valor_anterior, valor_nuevo)
    case campo
    when "nombre"
      "Nombre cambiado"
    when "descripcion"
      "Descripción modificada"
    when "precio_compra"
      "Precio de compra: #{valor_anterior} → #{valor_nuevo}"
    when "precio_venta"
      "Precio de venta: #{valor_anterior} → #{valor_nuevo}"
    when "precio"
      "Precio: #{valor_anterior} → #{valor_nuevo}"
    when "estado"
      "Estado: #{valor_anterior} → #{valor_nuevo}"
    when "etiqueta"
      "Etiqueta: #{valor_anterior} → #{valor_nuevo}"
    when "categoria"
      "Categoría: #{valor_anterior} → #{valor_nuevo}"
    when "fotos"
      "Fotos actualizadas"
    when "creado"
      "Producto creado"
    else
      "#{campo}: #{valor_anterior} → #{valor_nuevo}"
    end
  end
end

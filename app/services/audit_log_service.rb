class AuditLogService
  def initialize(producto)
    @producto = producto
  end

  def call
    return if Rails.env.test?

    editor = @producto.last_updated_by || @producto.user
    return unless editor.present?

    if @producto.saved_change_to_created_at?
      ProductoHistorial.registrar(@producto, editor, "creado", nil, "Producto creado", "Producto creado")
      return
    end

    return unless @producto.previous_changes.present?

    changes_to_track = {
      "nombre" => :nombre,
      "precio_compra" => :precio_compra,
      "precio_venta" => :precio_venta,
      "estado" => :estado,
      "etiqueta" => :etiqueta,
      "categoria_id" => :categoria_id
    }

    @producto.previous_changes.each do |attr, (valor_anterior, valor_nuevo)|
      campo = attr.to_s
      next unless changes_to_track.key?(campo)

      if campo == "categoria_id"
        valor_anterior = Categoria.find_by(id: valor_anterior)&.nombre || "Ninguna"
        valor_nuevo = Categoria.find_by(id: valor_nuevo)&.nombre || "Ninguna"
        campo = "categoria"
      end

      ProductoHistorial.registrar(@producto, editor, campo, valor_anterior.to_s, valor_nuevo.to_s)
    end
  end
end

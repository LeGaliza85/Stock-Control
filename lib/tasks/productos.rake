namespace :productos do
  desc "Generar códigos retroactivamente para productos existentes y prefijos para categorías"
  task generar_codigos: :environment do
    puts "=== Generando prefijos para categorías ==="

    # Procesar categorías en orden por primera letra
    categorias_ordenadas = Categoria.where(prefijo: nil).order(:id)

    categorias_ordenadas.each do |categoria|
      letra_base = categoria.nombre[0].upcase

      # Contar cuántas categorías empiezan con esta letra (procesadas hasta ahora)
      categorias_misma_letra = Categoria.where("UPPER(nombre) LIKE ?", "#{letra_base}%")
                                       .where.not(id: categoria.id)
                                       .where.not(prefijo: nil)
                                       .count

      # Posición = categorías ya procesadas + 1
      posicion = categorias_misma_letra + 1

      # Prefijo = primeras N letras según posición
      prefijo = categoria.nombre[0, posicion].upcase

      categoria.update_column(:prefijo, prefijo)
      puts "  #{categoria.nombre} → #{prefijo}"
    end

    puts "\n=== Generando códigos para productos ==="

    # Generar códigos para productos que no tienen
    Categoria.all.each do |categoria|
      productos_sin_codigo = categoria.productos.where(codigo: [nil, ""]).order(:created_at)

      productos_sin_codigo.each_with_index do |producto, index|
        codigo = "#{categoria.prefijo}#{index + 1}"
        producto.update_column(:codigo, codigo)
        puts "  #{producto.nombre} → #{codigo}"
      end
    end

    puts "\n=== Resumen ==="
    puts "Categorías: #{Categoria.count}"
    puts "Productos con código: #{Producto.where.not(codigo: [nil, ""]).count}"
    puts "Total productos: #{Producto.count}"
  end
end

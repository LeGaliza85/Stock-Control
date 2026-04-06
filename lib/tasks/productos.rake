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
      productos_sin_codigo = categoria.productos.where(codigo: [ nil, "" ]).order(:created_at)

      productos_sin_codigo.each_with_index do |producto, index|
        codigo = "#{categoria.prefijo}#{index + 1}"
        producto.update_column(:codigo, codigo)
        puts "  #{producto.nombre} → #{codigo}"
      end
    end

    puts "\n=== Resumen ==="
    puts "Categorías: #{Categoria.count}"
    puts "Productos con código: #{Producto.where.not(codigo: [ nil, "" ]).count}"
    puts "Total productos: #{Producto.count}"
  end

  desc "Generar embeddings para productos con fotos pero sin embedding"
  task generar_embeddings: :environment do
    puts "=== Generando embeddings para productos ==="

    productos_sin_embedding = Producto
      .joins(:fotos_attachments)
      .where("embedding IS NULL OR embedding = ''")
      .distinct

    puts "Productos a procesar: #{productos_sin_embedding.count}"

    if productos_sin_embedding.count.zero?
      puts "No hay productos que necesiten embeddings."
      return
    end

    productos_sin_embedding.each do |producto|
      puts "Procesando ##{producto.id}: #{producto.nombre}..."

      begin
        producto.generar_embedding
        if producto.embedding.present?
          puts "  ✓ Embedding guardado (#{JSON.parse(producto.embedding).length} dimensiones)"
        else
          puts "  ✗ Error: no se pudo generar embedding"
        end
      rescue => e
        puts "  ✗ Error: #{e.message}"
      end

      sleep 1.5
    end

    puts "\n=== Resumen ==="
    productos_con = Producto.where("embedding IS NOT NULL AND embedding != ''").count
    puts "Productos con embedding: #{productos_con}/#{Producto.count}"
  end

  desc "Regenerar TODOS los embeddings (formato uniforme)"
  task regenerar_embeddings: :environment do
    puts "=== Regenerando todos los embeddings ==="

    productos = Producto.joins(:fotos_attachments).distinct
    puts "Productos con fotos: #{productos.count}"

    require "clip"
    clip = $clip_model || Clip::Model.new

    productos.each do |producto|
      print "Procesando ##{producto.id}: #{producto.nombre}... "

      begin
        embeddings = []

        producto.fotos.each do |foto|
          begin
            blob = foto.blob
            image_binary = blob.download

            tmp = Tempfile.new(["clip", ".jpg"], binmode: true)
            tmp.write(image_binary)
            tmp.close

            emb = clip.encode_image(tmp.path)
            embeddings << emb if emb
            tmp.unlink
          rescue => e
            puts "(error foto: #{e.message})"
          end
        end

        if embeddings.any?
          producto.update_column(:embedding, embeddings.to_json)
          puts "OK (#{embeddings.length} fotos)"
        else
          puts "SIN EMBEDDING"
        end
      rescue => e
        puts "ERROR: #{e.message}"
      end

      sleep 0.5
    end

    total = Producto.where.not(embedding: nil).where("embedding != ?", "").count
    puts "\n=== Total con embedding: #{total} ==="
  end

  desc "Ver estado de embeddings en la base de datos"
  task verificar_embeddings: :environment do
    total = Producto.count
    con_fotos = Producto.joins(:fotos_attachments).distinct.count
    con_embedding = Producto.where("embedding IS NOT NULL AND embedding != ''").count
    sin_embedding = Producto.joins(:fotos_attachments).where("embedding IS NULL OR embedding = ''").distinct.count

    puts "=== Estado de Embeddings ==="
    puts "Total productos: #{total}"
    puts "Productos con fotos: #{con_fotos}"
    puts "Productos con embedding: #{con_embedding}"
    puts "Productos sin embedding (tienen fotos): #{sin_embedding}"

    if sin_embedding > 0
      puts "\nPara generar embeddings, ejecuta:"
      puts "  bin/rails productos:generar_embeddings"
    end
  end
end

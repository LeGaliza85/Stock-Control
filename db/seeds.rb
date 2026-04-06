require 'open-uri'

admin = User.find_or_create_by!(email_address: "admin@stockcontrol.com") do |user|
  user.nombre = "Admin"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.rol = :admin
end

visitante = User.find_or_create_by!(email_address: "visitante@stockcontrol.com") do |user|
  user.nombre = "Visitante"
  user.password = "visitante123"
  user.password_confirmation = "visitante123"
  user.rol = :visitante
end

puts "Usuarios creados: #{User.count}"

nombres_categorias = %w[Muebles Decoración Arte Vajilla Iluminación Textil Joyería Herramientas Libros Otros]
nombres_categorias.each do |nombre|
  Categoria.find_or_create_by!(nombre: nombre)
end

puts "Categorías creadas: #{Categoria.count}"

productos_seed = [
  { 
    nombre: "Silla Eames Blanca", 
    descripcion: "Silla de plástico moldeado con patas de madera.", 
    precio_compra: 45000, 
    precio_venta: 85000, 
    estado: :bueno, 
    categoria_id: Categoria.find_by!(nombre: "Muebles").id, 
    image_urls: [
      "https://images.unsplash.com/photo-1506439015949-bb88b021d743?w=800&q=80",
      "https://images.unsplash.com/photo-1592078615290-033ee584e267?w=800&q=80",
      "https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=800&q=80",
      "https://images.unsplash.com/photo-1581539250439-c966898956ae?w=800&q=80"
    ] 
  },
  { 
    nombre: "Lámpara industrial de pie", 
    descripcion: "Lámpara de pie en metal negro mate, estilo industrial moderno.", 
    precio_compra: 65000, 
    precio_venta: 120000, 
    estado: :bueno, 
    categoria_id: Categoria.find_by!(nombre: "Iluminación").id, 
    image_urls: [
      "https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?w=800&q=80",
      "https://images.unsplash.com/photo-1507473885765-e6ed057f7821?w=800&q=80",
      "https://images.unsplash.com/photo-1540932239986-30128078f3c5?w=800&q=80",
      "https://images.unsplash.com/photo-1524484485831-a92ffc0de03f?w=800&q=80"
    ] 
  },
  { 
    nombre: "Cámara Leica M3", 
    descripcion: "Cámara fotográfica analógica clásica Leica, funcionando.", 
    precio_compra: 180000, 
    precio_venta: 250000, 
    estado: :bueno, 
    categoria_id: Categoria.find_by!(nombre: "Arte").id, 
    image_urls: [
      "https://images.unsplash.com/photo-1516961642265-531546e84af2?w=800&q=80",
      "https://images.unsplash.com/photo-1500634245200-e5245c7574ef?w=800&q=80",
      "https://images.unsplash.com/photo-1496284427489-f59461d15605?w=800&q=80",
      "https://images.unsplash.com/photo-1552168324-d612d77725e3?w=800&q=80"
    ] 
  },
  { 
    nombre: "Juego de té japonés cerámica", 
    descripcion: "Set de tazas de cerámica tradicional japonesa.", 
    precio_compra: 20000, 
    precio_venta: 45000, 
    estado: :nuevo, 
    categoria_id: Categoria.find_by!(nombre: "Vajilla").id, 
    image_urls: [
      "https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=800&q=80",
      "https://images.unsplash.com/photo-1594489428504-5c0c480a15fd?w=800&q=80",
      "https://images.unsplash.com/photo-1563822249548-9a72b6353cd1?w=800&q=80",
      "https://images.unsplash.com/photo-1577805947697-89e18249d767?w=800&q=80"
    ] 
  },
  { 
    nombre: "Reloj de bolsillo antiguo", 
    descripcion: "Reloj de bolsillo vintage con mecanismo expuesto.", 
    precio_compra: 35000, 
    precio_venta: 75000, 
    estado: :para_restaurar, 
    categoria_id: Categoria.find_by!(nombre: "Joyería").id, 
    image_urls: [
      "https://images.unsplash.com/photo-1622434641406-a158123450f9?w=800&q=80",
      "https://images.unsplash.com/photo-1509048191080-d2984bad6ae5?w=800&q=80",
      "https://images.unsplash.com/photo-1501139083538-0139583c060f?w=800&q=80",
      "https://images.unsplash.com/photo-1495364141860-b0d03eae1f71?w=800&q=80"
    ] 
  },
  { 
    nombre: "Escritorio de roble rústico", 
    descripcion: "Mesa de trabajo rústica de madera de roble.", 
    precio_compra: 150000, 
    precio_venta: 280000, 
    estado: :desgastado, 
    categoria_id: Categoria.find_by!(nombre: "Muebles").id, 
    image_urls: [
      "https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=800&q=80",
      "https://images.unsplash.com/photo-1519643381401-22c77e60520e?w=800&q=80",
      "https://images.unsplash.com/photo-1499933374294-4584851497cc?w=800&q=80",
      "https://images.unsplash.com/photo-1533090161767-e6ffed986c88?w=800&q=80"
    ] 
  },
  { 
    nombre: "Florero cristal minimalista", 
    descripcion: "Florero de cristal tintado moderno.", 
    precio_compra: 15000, 
    precio_venta: 38000, 
    estado: :bueno, 
    categoria_id: Categoria.find_by!(nombre: "Decoración").id, 
    image_urls: [
      "https://images.unsplash.com/photo-1581783898377-1c85bf937427?w=800&q=80",
      "https://images.unsplash.com/photo-1603514489569-87b3227415bc?w=800&q=80",
      "https://images.unsplash.com/photo-1581783342308-f792db82040a?w=800&q=80",
      "https://images.unsplash.com/photo-1578500494198-246f612d3b3d?w=800&q=80"
    ] 
  },
  { 
    nombre: "Alfombra tejida geométrica", 
    descripcion: "Alfombra artesanal tejida a mano, patrones geométricos.", 
    precio_compra: 120000, 
    precio_venta: 250000, 
    estado: :nuevo, 
    categoria_id: Categoria.find_by!(nombre: "Textil").id, 
    image_urls: [
      "https://images.unsplash.com/photo-1600166898405-da9535204843?w=800&q=80",
      "https://images.unsplash.com/photo-1534889156217-d643df14f14a?w=800&q=80",
      "https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=800&q=80",
      "https://images.unsplash.com/photo-1575414003593-0a3cb98ee4ee?w=800&q=80"
    ] 
  },
  { 
    nombre: "Máquina de escribir Royal", 
    descripcion: "Máquina de escribir verde clásica, revisada.", 
    precio_compra: 90000, 
    precio_venta: 180000, 
    estado: :bueno, 
    categoria_id: Categoria.find_by!(nombre: "Otros").id, 
    image_urls: [
      "https://images.unsplash.com/photo-1522080356930-b1a7af99d4fb?w=800&q=80",
      "https://images.unsplash.com/photo-1455389658237-77fb2d5565f4?w=800&q=80",
      "https://images.unsplash.com/photo-1490333246837-76ceb1d62c9c?w=800&q=80",
      "https://images.unsplash.com/photo-1586075010923-2dd4570fb338?w=800&q=80"
    ] 
  },
  { 
    nombre: "Colección libros antiguos", 
    descripcion: "Libros encuadernados en cuero oscuro.", 
    precio_compra: 60000, 
    precio_venta: 130000, 
    estado: :aceptable, 
    categoria_id: Categoria.find_by!(nombre: "Libros").id, 
    image_urls: [
      "https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=800&q=80",
      "https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=800&q=80",
      "https://images.unsplash.com/photo-1526243741027-444d633d7365?w=800&q=80",
      "https://images.unsplash.com/photo-1457369804613-52c61a468e7d?w=800&q=80"
    ] 
  }
]

users = [ admin, visitante ]

productos_seed.each_with_index do |attrs, index|
  image_urls = attrs.delete(:image_urls)
  producto = Producto.find_by(nombre: attrs[:nombre])
  
  unless producto
    puts "Creando producto #{index + 1}/#{productos_seed.length}: #{attrs[:nombre]}..."
    
    p = Producto.new(attrs.merge(user: users.sample))
    
    images_attached = 0
    image_urls.each_with_index do |url, i|
      break if images_attached >= 3 # Límite de 3 imágenes exitosas por producto
      
      begin
        print "  Intentando descargar foto #{i + 1}..."
        downloaded_image = URI.open(url)
        p.fotos.attach(io: downloaded_image, filename: "image_#{index}_#{i}.jpg", content_type: "image/jpeg")
        puts " [OK]"
        images_attached += 1
      rescue => e
        puts " [Fallo: #{e.message}] - Buscando siguiente..."
      end
    end
    
    if p.save
      puts "  -> Producto guardado con #{images_attached} fotos."
    else
      puts "  -> Error al guardar: #{p.errors.full_messages.join(', ')}"
    end
  else
    puts "Producto ya existe: #{attrs[:nombre]}"
  end
end

puts "\nProcesando embeddings (síncrono para el seed)..."
ImageEmbeddingService.clip_model

Producto.where(embedding: nil).find_each do |p|
  if p.fotos.attached?
    print "Generando embedding para #{p.nombre}... "
    GenerateEmbeddingJob.perform_now(p.id)
    puts "Hecho."
  end
end

puts "\nResumen:"
puts "Productos totales: #{Producto.count}"
puts "Productos con embedding: #{Producto.where.not(embedding: nil).count}"
puts "Total de fotos adjuntas en el sistema: #{ActiveStorage::Attachment.count}"
admin = User.find_or_create_by!(email_address: "admin@stockcontrol.com") do |user|
  user.nombre = "Admin"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.rol = :admin
end

miembro = User.find_or_create_by!(email_address: "miembro@stockcontrol.com") do |user|
  user.nombre = "Miembro"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.rol = :miembro
end

puts "Usuarios creados: #{User.count}"

nombres_categorias = %w[Muebles Decoración Arte Vajilla Iluminación Textil Joyería Herramientas Libros Otros]
nombres_categorias.each do |nombre|
  Categoria.find_or_create_by!(nombre: nombre)
end

puts "Categorías creadas: #{Categoria.count}"

productos = [
  # Muebles
  { nombre: "Cómoda victoriana de caoba", descripcion: "Cómoda de caoba maciza con cinco cajones, tiradores de bronce originales y tapa de mármol gris. Fabricación inglesa, excelente estado de conservación. Pequeña restauración en la pata trasera izquierda.", precio_compra: 280000, precio_venta: 450000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Muebles").id },
  { nombre: "Mesa de comedor art déco", descripcion: "Mesa extensible de nogal con patas geométricas características del estilo art déco. Incluye dos tablas de extensión. Superficie con pátina natural.", precio_compra: 350000, precio_venta: 580000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Muebles").id },
  { nombre: "Silla Thonet N°14 original", descripcion: "Icónica silla de madera curvada diseñada por Michael Thonet. Sello original en la base. Asiento de rejilla en buen estado.", precio_compra: 85000, precio_venta: 145000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Muebles").id },
  { nombre: "Escritorio rolltop de roble", descripcion: "Escritorio americano con persiana enrollable, múltiples compartimentos interiores y cajones laterales. Cerradura original funcional con llave.", precio_compra: 420000, precio_venta: 680000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Muebles").id },
  { nombre: "Baúl de viaje Louis Vuitton", descripcion: "Baúl de viaje con monograma LV, estructura de madera con refuerzos de latón. Interior con bandeja extraíble. Algunos desgastes en las esquinas propios del uso.", precio_compra: 1200000, precio_venta: 2100000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Muebles").id },
  { nombre: "Mecedora colonial chilena", descripcion: "Mecedora de madera nativa con asiento y respaldo de cuero repujado. Estilo colonial típico del sur de Chile. Estructura firme y funcional.", precio_compra: 120000, precio_venta: 195000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Muebles").id },

  # Decoración
  { nombre: "Reloj de pared Junghans", descripcion: "Reloj de péndulo alemán con caja de nogal tallada. Maquinaria original funcionando. Sonería de campana cada media hora. Incluye llave de cuerda.", precio_compra: 150000, precio_venta: 265000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Decoración").id },
  { nombre: "Espejo biselado marco dorado", descripcion: "Gran espejo con marco de madera tallada y dorada a la hoja. Cristal biselado original con leve oxidación en los bordes. Medidas: 120x80 cm.", precio_compra: 180000, precio_venta: 320000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Decoración").id },
  { nombre: "Candelabro de bronce 5 brazos", descripcion: "Candelabro de mesa de bronce macizo con cinco brazos y base decorada con motivos vegetales. Pátina verde natural. Peso: 3.2 kg.", precio_compra: 65000, precio_venta: 110000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Decoración").id },
  { nombre: "Jarrón cloisonné chino", descripcion: "Jarrón de esmalte cloisonné con motivos florales sobre fondo azul cobalto. Base de bronce dorado. Altura: 35 cm. Sin grietas ni reparaciones.", precio_compra: 95000, precio_venta: 175000, estado: :nuevo, categoria_id: Categoria.find_by!(nombre: "Decoración").id },
  { nombre: "Globo terráqueo vintage", descripcion: "Globo terráqueo sobre base de madera torneada con meridiano de latón. Mapa político de la época con fronteras pre-guerra. Gira suavemente.", precio_compra: 55000, precio_venta: 92000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Decoración").id },

  # Arte
  { nombre: "Óleo paisaje costumbrista chileno", descripcion: "Pintura al óleo sobre tela representando un paisaje rural del valle central. Marco de madera dorada original. Firmado por el artista en esquina inferior derecha. Medidas con marco: 80x60 cm.", precio_compra: 250000, precio_venta: 420000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Arte").id },
  { nombre: "Grabado botánico enmarcado", descripcion: "Grabado coloreado a mano de especie botánica nativa. Papel de algodón con marcas de agua. Marco de madera oscura con passepartout crema.", precio_compra: 35000, precio_venta: 68000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Arte").id },
  { nombre: "Escultura de bronce Art Nouveau", descripcion: "Figura femenina en bronce patinado sobre base de mármol negro. Estilo Art Nouveau con líneas fluidas. Altura total: 42 cm. Firmada en la base.", precio_compra: 380000, precio_venta: 620000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Arte").id },
  { nombre: "Litografía Toulouse-Lautrec (reproducción)", descripcion: "Reproducción numerada de cartel del Moulin Rouge. Impresión sobre papel artesanal. Enmarcada con vidrio museográfico. Edición limitada 120/500.", precio_compra: 45000, precio_venta: 78000, estado: :nuevo, categoria_id: Categoria.find_by!(nombre: "Arte").id },

  # Vajilla
  { nombre: "Juego de té porcelana Limoges", descripcion: "Set completo de 6 servicios: tetera, azucarera, cremera, 6 tazas con platos. Porcelana blanca con filete dorado y motivo floral rosa. Sin chips ni reparaciones.", precio_compra: 120000, precio_venta: 210000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Vajilla").id },
  { nombre: "Sopera de loza inglesa Wedgwood", descripcion: "Sopera ovalada con tapa y asas, patrón Blue Willow clásico. Sello de Wedgwood en la base. Capacidad aproximada 3 litros.", precio_compra: 75000, precio_venta: 130000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Vajilla").id },
  { nombre: "Set 12 copas cristal Bohemia", descripcion: "Doce copas de vino tinto en cristal tallado de Bohemia. Patrón de diamante. Todas en perfecto estado, sin chips. Caja original.", precio_compra: 95000, precio_venta: 165000, estado: :nuevo, categoria_id: Categoria.find_by!(nombre: "Vajilla").id },
  { nombre: "Plato decorativo Talavera", descripcion: "Plato de cerámica pintado a mano con motivos tradicionales en azul y amarillo. Diámetro: 32 cm. Con soporte de exhibición.", precio_compra: 28000, precio_venta: 48000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Vajilla").id },

  # Iluminación
  { nombre: "Lámpara Tiffany de mesa", descripcion: "Lámpara de mesa estilo Tiffany con pantalla de vidrio emplomado en tonos ámbar, verde y azul. Base de bronce patinado. Altura: 55 cm. Funcional.", precio_compra: 280000, precio_venta: 480000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Iluminación").id },
  { nombre: "Araña de cristal 8 luces", descripcion: "Araña de techo con estructura de bronce dorado y caireles de cristal. Ocho brazos con portavelas adaptados a electricidad. Diámetro: 70 cm.", precio_compra: 350000, precio_venta: 590000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Iluminación").id },
  { nombre: "Farol de cobre marino", descripcion: "Farol de barco en cobre y vidrio, con asa superior. Originalmente a aceite, adaptado a electricidad. Pátina verde natural. Altura: 40 cm.", precio_compra: 65000, precio_venta: 115000, estado: :desgastado, categoria_id: Categoria.find_by!(nombre: "Iluminación").id },

  # Textil
  { nombre: "Alfombra persa Tabriz", descripcion: "Alfombra anudada a mano en lana y seda. Medallón central con motivos florales sobre fondo rojo burdeos. Medidas: 200x300 cm. Flecos originales.", precio_compra: 450000, precio_venta: 780000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Textil").id },
  { nombre: "Tapiz flamenco escena pastoral", descripcion: "Tapiz tejido a máquina reproduciendo escena pastoral del siglo XVIII. Colores bien conservados. Barra de colgar incluida. Medidas: 150x100 cm.", precio_compra: 85000, precio_venta: 145000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Textil").id },

  # Joyería
  { nombre: "Broche camafeo victoriano", descripcion: "Camafeo tallado en concha con perfil femenino clásico. Montura de plata con filigrana. Cierre de aguja seguro. Diámetro: 4.5 cm.", precio_compra: 45000, precio_venta: 82000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Joyería").id },
  { nombre: "Reloj de bolsillo Omega", descripcion: "Reloj de bolsillo en caja de plata con tapa lisa grabable. Movimiento mecánico de cuerda manual funcionando. Esfera blanca con números romanos. Incluye cadena.", precio_compra: 180000, precio_venta: 310000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Joyería").id },

  # Herramientas
  { nombre: "Set carpintería Stanley vintage", descripcion: "Caja de herramientas de carpintero con cepillo Stanley N°4, formones, serrucho de costilla y escuadra. Todo en estado funcional. Caja de madera original.", precio_compra: 55000, precio_venta: 95000, estado: :desgastado, categoria_id: Categoria.find_by!(nombre: "Herramientas").id },
  { nombre: "Máquina de coser Singer", descripcion: "Máquina de coser Singer con mueble de hierro forjado y pedal. Modelo 66 con decoración de esfinge dorada. Funcional tras mantenimiento. Incluye accesorios originales.", precio_compra: 120000, precio_venta: 210000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Herramientas").id },

  # Libros
  { nombre: "Atlas geográfico 1920", descripcion: "Atlas mundial encuadernado en cuero con mapas a color. Fronteras de la época post Primera Guerra Mundial. Algunas páginas con foxing leve. Lomo reforzado.", precio_compra: 65000, precio_venta: 115000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Libros").id },
  { nombre: "Enciclopedia Británica 1911 (3 tomos)", descripcion: "Tres tomos de la famosa 11ª edición de la Enciclopedia Británica. Encuadernación en tela azul con letras doradas. Páginas en buen estado.", precio_compra: 85000, precio_venta: 150000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Libros").id },
  { nombre: "Libro primeras ediciones Pablo Neruda", descripcion: "Primera edición de 'Veinte poemas de amor' con cubierta original. Algunas manchas de humedad en las guardas. Interior limpio y legible.", precio_compra: 350000, precio_venta: 600000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Libros").id },

  # Otros
  { nombre: "Gramófono Columbia portátil", descripcion: "Gramófono portátil en maleta de cuero con manivela de cuerda. Reproduce discos de 78 RPM. Bocina interna. Aguja de repuesto incluida. Sonido sorprendentemente bueno.", precio_compra: 150000, precio_venta: 260000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Otros").id },
  { nombre: "Cámara Rolleiflex TLR", descripcion: "Cámara réflex de doble lente Rolleiflex para película 120. Lentes Zeiss Tessar. Obturador funcionando en todas las velocidades. Con estuche de cuero.", precio_compra: 220000, precio_venta: 380000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Otros").id },
  { nombre: "Telescopio naval de latón", descripcion: "Telescopio extensible de latón con óptica funcional. Tres secciones extensibles. Largo total: 60 cm. Con funda de cuero.", precio_compra: 75000, precio_venta: 135000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Otros").id },
  { nombre: "Máquina de escribir Olivetti Lettera 32", descripcion: "Icónica máquina de escribir portátil en color turquesa. Todas las teclas funcionan. Cinta nueva instalada. Con maletín original.", precio_compra: 95000, precio_venta: 165000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Otros").id },
  { nombre: "Teléfono de baquelita negro", descripcion: "Teléfono de disco en baquelita negra con base metálica. Disco giratorio suave. Cable de tela original. Puramente decorativo, no adaptado a línea moderna.", precio_compra: 40000, precio_venta: 72000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Otros").id }
]

users = [ admin, miembro ]

productos.each do |attrs|
  Producto.find_or_create_by!(nombre: attrs[:nombre]) do |p|
    p.assign_attributes(attrs.merge(user: users.sample))
  end
end

puts "Productos creados: #{Producto.count}"

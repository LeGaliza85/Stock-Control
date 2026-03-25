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
  { nombre: "Teléfono de baquelita negro", descripcion: "Teléfono de disco en baquelita negra con base metálica. Disco giratorio suave. Cable de tela original. Puramente decorativo, no adaptado a línea moderna.", precio_compra: 40000, precio_venta: 72000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Otros").id },

  # --- 50 productos extra ---
  { nombre: "Silla de oficina industrial", descripcion: "Silla giratoria con estructura de hierro y asiento de cuero desgastado. Altura regulable. Estilo industrial vintage.", precio_compra: 45000, precio_venta: 85000, estado: :desgastado, categoria_id: Categoria.find_by!(nombre: "Muebles").id },
  { nombre: "Cómoda provenzal pintada", descripcion: "Cómoda de pino con detalles florales pintados a mano. Tres cajones con tiradores de porcelana. Estilo provenzal.", precio_compra: 180000, precio_venta: 310000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Muebles").id },
  { nombre: "Sillón Chesterfield", descripcion: "Sillón de dos plazas tapizado en cuero marrón clásico con botones profundos. Patas de madera torneada.", precio_compra: 320000, precio_venta: 550000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Muebles").id },
  { nombre: "Mesa auxiliar art nouveau", descripcion: "Mesa de centro con patas curvadas y vidrio biselado. Detalles florales en hierro forjado.", precio_compra: 95000, precio_venta: 175000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Muebles").id },
  { nombre: "Estantería de escalera", descripcion: "Estantería de madera de pino con forma de escalera. Cinco niveles de diferente profundidad. Estilo rústico.", precio_compra: 65000, precio_venta: 120000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Muebles").id },
  { nombre: "Cuna antigua de madera", descripcion: "Cuna de mecedor en madera de raulí con barrotes torneados. Incluye colchón nuevo. Finales del siglo XIX.", precio_compra: 150000, precio_venta: 260000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Muebles").id },
  { nombre: "Tocador con espejo oval", descripcion: "Tocador de nogal con espejo oval inclinado y tres cajones laterales. Pintura original en buen estado.", precio_compra: 220000, precio_venta: 380000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Muebles").id },
  { nombre: "Banco de iglesia", descripcion: "Banco largo de pino macizo proveniente de una capilla. Asiento de tablones con respaldo bajo. Marca de desgaste natural.", precio_compra: 75000, precio_venta: 135000, estado: :desgastado, categoria_id: Categoria.find_by!(nombre: "Muebles").id },
  { nombre: "Consola con patas cabriolé", descripcion: "Consola de caoba con tapa de mármol gris y patas cabriolé talladas. Cajón central funcional.", precio_compra: 190000, precio_venta: 340000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Muebles").id },
  { nombre: "Vitrina de cristal con llave", descripcion: "Vitrina vertical con puertas de cristal y base de madera oscura. Interior con estantes de vidrio. Cerradura original con llave.", precio_compra: 280000, precio_venta: 480000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Muebles").id },

  { nombre: "Lámpara de pie art nouveau", descripcion: "Lámpara de pie con pantalla de vidrio emplomado en tonos verde y ámbar. Base de bronce con figura femenina.", precio_compra: 180000, precio_venta: 320000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Iluminación").id },
  { nombre: "Farol de entrada colonial", descripcion: "Farol de pared en hierro forjado con vidrio biselado. Ideal para entrada o pasillo. Estilo colonial.", precio_compra: 55000, precio_venta: 98000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Iluminación").id },
  { nombre: "Lámpara de escritorio verde", descripcion: "Lámpara de mesa con pantalla de vidrio verde oscuro y base de bronce. Estilo banquero clásico.", precio_compra: 45000, precio_venta: 82000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Iluminación").id },
  { nombre: "Araña pequeña 4 brazos", descripcion: "Candelabro de techo con cuatro brazos y caireles de cristal cortado. Diámetro: 45 cm. Estilo Luis XV.", precio_compra: 150000, precio_venta: 270000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Iluminación").id },
  { nombre: "Linterna japonesa de papel", descripcion: "Linterna esférica de papel de arroz sobre estructura de bambú. Incluye soporte de techo. Decorativa.", precio_compra: 25000, precio_venta: 45000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Iluminación").id },

  { nombre: "Vitrina reloj de pared", descripcion: "Vitrina colgante con puerta de vidrio y estante interior. Ideal para exhibir piezas pequeñas o relojes.", precio_compra: 35000, precio_venta: 65000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Decoración").id },
  { nombre: "Cuadro marina oleo", descripcion: "Óleo sobre lienzo de temática marina con barco de vela. Marco dorado tallado a mano. Artista desconocido.", precio_compra: 120000, precio_venta: 210000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Arte").id },
  { nombre: "Reloj despertador soviético", descripcion: "Reloj despertador de mesa de origen soviético con campana superior. Funcional. Caja de metal cromado.", precio_compra: 15000, precio_venta: 35000, estado: :desgastado, categoria_id: Categoria.find_by!(nombre: "Otros").id },
  { nombre: "Juego de café Wedgwood", descripcion: "Set de 6 tazas y platos de porcelana Wedgwood con motivo jasperware azul. Sin chips.", precio_compra: 85000, precio_venta: 155000, estado: :nuevo, categoria_id: Categoria.find_by!(nombre: "Vajilla").id },
  { nombre: "Platón de peltre", descripcion: "Platón ovalado de peltre con borde repujado. Marca de fabricante en la base. Siglo XIX.", precio_compra: 30000, precio_venta: 55000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Vajilla").id },
  { nombre: "Copa de champagne cristal", descripcion: "Par de copas de champagne en cristal tallado con pie hexagonal. Sin restauraciones.", precio_compra: 40000, precio_venta: 72000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Vajilla").id },
  { nombre: "Azucarera de plata con cuchara", descripcion: "Azucarera de plata 950 con tapa y cuchara de servir. Grabados florales. Peso: 180g.", precio_compra: 65000, precio_venta: 120000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Vajilla").id },
  { nombre: "Jarra de cerámica pintada", descripcion: "Jarra de gres con motivos florales en tonos azules y verdes. Asa ancha. Altura: 25 cm.", precio_compra: 22000, precio_venta: 42000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Vajilla").id },

  { nombre: "Grabado mapa antiguo", descripcion: "Grabado en blanco y negro de mapa del Pacífico Sur, siglo XVIII. Enmarcado con paspartú.", precio_compra: 35000, precio_venta: 68000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Arte").id },
  { nombre: "Acuarela siglo XIX", descripcion: "Acuarela de paisaje campestre con molino. Firmada ilegible. Marco de madera original.", precio_compra: 85000, precio_venta: 160000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Arte").id },
  { nombre: "Estatuilla de bronce", descripcion: "Estatuilla de bronce patinado de figura ecuestre. Base de mármol negro. Altura: 28 cm.", precio_compra: 110000, precio_venta: 195000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Arte").id },
  { nombre: "Fotografía daguerrotipo", descripcion: "Retrato en daguerrotipo con marco de metal y estuche de terciopelo. Mediados del siglo XIX.", precio_compra: 55000, precio_venta: 95000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Arte").id },
  { nombre: "Litografía Cheret", descripcion: "Litografía coloreada de cartel publicitario estilo Art Nouveau por Jules Cheret. Enmarcada.", precio_compra: 120000, precio_venta: 220000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Arte").id },

  { nombre: "Alfombra kilim turco", descripcion: "Alfombra kilim tejida a mano en lana con motivos geométricos. Colores naturales. Medidas: 180x120 cm.", precio_compra: 95000, precio_venta: 175000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Textil").id },
  { nombre: "Colcha patchwork", descripcion: "Colcha de patchwork con piezas de algodón estampado. Siglo XX. Reverso de percal liso.", precio_compra: 35000, precio_venta: 65000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Textil").id },
  { nombre: "Tapiz persa de seda", descripcion: "Mini tapiz persa tejido en seda y lana con escena de jardín. Medidas: 60x40 cm. Enmarcado.", precio_compra: 75000, precio_venta: 140000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Textil").id },
  { nombre: "Cortinas de encaje", descripcion: "Par de cortinas de encaje blanco con motivos florales. Largo: 240 cm. Estilo victoriano.", precio_compra: 28000, precio_venta: 52000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Textil").id },

  { nombre: "Collar de perlas", descripcion: "Collar de perlas de agua dulce con cierre de plata. Largo: 45 cm. Nudo entre cada perla.", precio_compra: 65000, precio_venta: 120000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Joyería").id },
  { nombre: "Anillo art déco zafiro", descripcion: "Anillo de oro blanco con zafiro central y diamantes laterales. Talla 14. Certificado incluido.", precio_compra: 250000, precio_venta: 450000, estado: :nuevo, categoria_id: Categoria.find_by!(nombre: "Joyería").id },
  { nombre: "Pulsera de plata antigua", descripcion: "Pulsera rígida de plata con motivos precolombinos. Artesanía chilena. Peso: 45g.", precio_compra: 35000, precio_venta: 68000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Joyería").id },
  { nombre: "Pasador de cabello marfil", descripcion: "Pasador de cabello tallado en marfil con figura de flor. Siglo XIX. En estuche de terciopelo.", precio_compra: 45000, precio_venta: 85000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Joyería").id },

  { nombre: "Sierra de mano antigua", descripcion: "Sierra de mano con hoja de acero y mango de madera con incrustaciones. Marca Diston. Siglo XIX.", precio_compra: 18000, precio_venta: 38000, estado: :desgastado, categoria_id: Categoria.find_by!(nombre: "Herramientas").id },
  { nombre: "Plomada de bronce", descripcion: "Plomada de bronce con grabado de iniciales. Usada en construcción naval. Siglo XIX.", precio_compra: 12000, precio_venta: 28000, estado: :desgastado, categoria_id: Categoria.find_by!(nombre: "Herramientas").id },
  { nombre: "Taladro manual vintage", descripcion: "Taladro de arco con mecanismo de piñón y corona. Mango de madera original. Funcional.", precio_compra: 22000, precio_venta: 42000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Herramientas").id },
  { nombre: "Caja de herramientas Stanley", descripcion: "Caja de metal con compartimentos Stanley. Contiene llaves, destornilladores y llaves inglesas vintage.", precio_compra: 65000, precio_venta: 115000, estado: :desgastado, categoria_id: Categoria.find_by!(nombre: "Herramientas").id },

  { nombre: "Don Quijote edición ilustrada", descripcion: "Don Quijote de la Mancha con ilustraciones de Gustave Doré. Encuadernación en tela con letras doradas.", precio_compra: 45000, precio_venta: 85000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Libros").id },
  { nombre: "Guía telefónica 1950", descripcion: "Guía telefónica de Santiago de Chile, año 1950. Cubierta de papel kraft. Interesante documento histórico.", precio_compra: 15000, precio_venta: 32000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Libros").id },
  { nombre: "Biblia ilustrada 1920", descripcion: "Biblia con grabados en negro y encuadernación en cuero repujado. Dedicatoria manuscrita de 1923.", precio_compra: 35000, precio_venta: 68000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Libros").id },
  { nombre: "Diccionario Larousse 1930", descripcion: "Diccionario enciclopédico Larousse en español. Tomo único con láminas a color. Lomo reforzado.", precio_compra: 25000, precio_venta: 48000, estado: :aceptable, categoria_id: Categoria.find_by!(nombre: "Libros").id },

  { nombre: "Brújula náutica", descripcion: "Brújula de navegación en latón con caja de madera. Aguja magnética funcional. Grabado de rosa de los vientos.", precio_compra: 45000, precio_venta: 82000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Otros").id },
  { nombre: "Calculadora mecánica", descripcion: "Calculadora mecánica de sobremesa marca Curta. Mecanismo de cigüeñal funcional. Incluye estuche.", precio_compra: 120000, precio_venta: 220000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Otros").id },
  { nombre: "Reloj de sol portátil", descripcion: "Reloj de sol de latón con brújula integrada. Firma de fabricante. Siglo XVIII. Estuche de cuero.", precio_compra: 85000, precio_venta: 160000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Otros").id },
  { nombre: "Frasco de farmacia antiguo", descripcion: "Frasco de vidrio soplado con etiqueta farmacéutica de porcelana. Tapón original. Siglo XIX.", precio_compra: 18000, precio_venta: 38000, estado: :bueno, categoria_id: Categoria.find_by!(nombre: "Otros").id },
  { nombre: "Pizarra de escuela antigua", descripcion: "Pizarra de pizarra con marco de madera y repisa para tiza. Tamaño pequeño. Estilo escuela rural.", precio_compra: 25000, precio_venta: 48000, estado: :desgastado, categoria_id: Categoria.find_by!(nombre: "Otros").id }
]

users = [ admin, miembro ]

productos.each do |attrs|
  Producto.find_or_create_by!(nombre: attrs[:nombre]) do |p|
    p.assign_attributes(attrs.merge(user: users.sample))
  end
end

puts "Productos creados: #{Producto.count}"

require "tempfile"
require "base64"

class ProductoBusquedaService
  EXCLUDE_KEYWORDS = [
    "no visible", "no detectable", "no perceptible",
    "no identificado", "no determinado", "ninguna", "ninguno"
  ].freeze

  def initialize(user)
    @user = user
  end

  def buscar_por_imagen(image_data)
    # Parse data:image/jpeg;base64,... format
    if match_data = image_data.match(/\Adata:([-\w]+\/[-\w\+\.]+)?;base64,(.*)/m)
      extension = match_data[1] ? match_data[1].split('/').last : 'jpeg'
      base64_string = match_data[2]
    else
      return { error: "Formato de imagen inválido" }
    end

    image_binary = Base64.decode64(base64_string)
    
    embedding = nil
    Tempfile.create(['search', ".#{extension}"]) do |tmp|
      tmp.binmode
      tmp.write(image_binary)
      tmp.rewind
      
      embedding = ImageEmbeddingService.generate(tmp.path)
    end

    if embedding.present?
      buscar_con_clip(embedding)
    else
      { error: "No se pudo procesar la imagen para búsqueda." }
    end
  rescue => e
    Rails.logger.error "Error al buscar por imagen: #{e.message}\n#{e.backtrace.join("\n")}"
    { error: "Error al analizar imagen: #{e.message}" }
  end

  private

  def buscar_con_clip(embedding)
    resultados = Producto.buscar_por_embedding(embedding, limit: 5)
    {
      analisis: { "descripcion" => "Búsqueda por similitud visual" },
      productos: resultados,
      metodo: "clip"
    }
  end
end

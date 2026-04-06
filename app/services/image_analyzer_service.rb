require "net/http"
require "json"

class ImageAnalyzerService
  GEMINI_MODELS = {
    "gemini-2.5-flash" => { input_cost: 0.30, output_cost: 2.50, context: "1M" },
    "gemini-3-flash-preview" => { input_cost: 0.10, output_cost: 0.40, context: "1M" },
    "gemini-2.5-flash-lite" => { input_cost: 0.075, output_cost: 0.30, context: "1M" }
  }.freeze

  OPENROUTER_MODELS = [
    "google/gemini-2.5-flash",
    "google/gemini-1.5-flash-8k",
    "google/gemini-pro-vision"
  ].freeze

  MOONDREAM_CLOUD_URL = "https://api.moondream.ai".freeze
  GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models".freeze
  OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions".freeze

  CLIP_MODEL_NAME = "clip-ViT-B-32"

  def initialize(user)
    @user = user
    @ia_service = user.ia_service || "gemini"
    @gemini_model = user.gemini_model || "gemini-2.5-flash"
    @clip_model = nil
  end

  def analyze(image_data, model: nil)
    IaUsage.record_request(@user, @ia_service)

    case @ia_service
    when "gemini"
      analyze_with_gemini(image_data, model: model || @gemini_model)
    when "openrouter"
      analyze_with_openrouter(image_data)
    else
      raise ArgumentError, "Servicio de IA no soportado: #{@ia_service}"
    end
  end

  def available_services
    [
      { id: "gemini", name: "Google Gemini", free: true, description: "Selección de modelos Gemini" },
      { id: "openrouter", name: "OpenRouter (Gemini)", free: true, description: "Gemini a través de OpenRouter con fallback automático" }
    ]
  end

  private

  def analyze_with_gemini(image_data, model:)
    api_key = ENV["GEMINI_API_KEY"]

    if api_key.nil? || api_key.empty? || api_key == "tu_api_key_aqui"
      return {
        error: "API key de Gemini no configurada. Contacta al administrador.",
        confianza: 0,
        necesita_config: true
      }
    end

    base64_image = prepare_image(image_data)

    prompt = <<~PROMPT
      Analiza esta imagen de un producto y proporciona:
      1. **Descripción**: Una descripción detallada del producto (qué es, materiales, colores, estilo, estado apparent)
      2. **Categoría sugerida**: La categoría más apropiada para este producto
      3. **Tipo de producto**: Clasificación general (ej: mueble, electrónico, ropa, juguete, etc.)
      4. **Marca/Modelo** (si es identificable): Cualquier marca o modelo visible
      5. **Estado aparente**: Evaluación del estado del producto (nuevo, bueno, aceptable, desgastado)
      6. **Posibles etiquetas**: Etiquetas sugeridas (en_venta, reservado, vendido, en_restauracion)
      7. **Confianza**: Porcentaje del 0-100% indicando qué tan seguro estás de la identificación del producto

      Responde SOLO en JSON con este formato exacto:
      {
        "descripcion": "...",
        "categoria_sugerida": "...",
        "tipo_producto": "...",
        "marca_modelo": "...",
        "estado": "nuevo|bueno|aceptable|desgastado|para_restaurar",
        "etiqueta": "en_venta|reservado|vendido|en_restauracion",
        "confianza": 0-100,
        "errores": ["..."]
      }
    PROMPT

    uri = URI("#{GEMINI_URL}/#{model}:generateContent?key=#{api_key}")
    request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json")
    request.body = {
      contents: [ {
        parts: [
          { text: prompt },
          { inline_data: { mime_type: detect_mime_type(image_data), data: base64_image } }
        ]
      } ],
      generationConfig: {
        responseMimeType: "application/json",
        temperature: 0.3
      }
    }.to_json

    response = make_request(uri, request)
    parse_gemini_response(response)
  rescue => e
    { error: "Error con Gemini: #{e.message}", confianza: 0 }
  end

  def analyze_with_moondream(image_data)
    api_key = ENV["MOONDREAM_API_KEY"]

    if api_key.nil? || api_key.empty?
      return {
        error: "API key de Moondream no configurada. Contacta al administrador.",
        confianza: 0,
        necesita_config: true
      }
    end

    base64_image = prepare_image(image_data)

    uri = URI("#{MOONDREAM_CLOUD_URL}/v1/chat/completions")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 30
    http.read_timeout = 60

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["Authorization"] = "Bearer #{api_key}"
    request.body = {
      model: "moondream-2B",
      messages: [
        {
          role: "user",
          content: "Analiza esta imagen de un producto y proporciona una descripción detallada en español, categoría sugerida, tipo de producto, marca/modelo (si identificable), estado aparente (nuevo/bueno/aceptable/desgastado/para_restaurar), etiquetas sugeridas (en_venta/reservado/vendido/en_restauracion) y confianza del 0-100%. Responde SOLO en JSON con este formato exacto: {\"descripcion\":\"...\",\"categoria_sugerida\":\"...\",\"tipo_producto\":\"...\",\"marca_modelo\":\"...\",\"estado\":\"...\",\"etiqueta\":\"...\",\"confianza\":0-100}. No escribas nada más que el JSON."
        }
      ],
      stream: false
    }.to_json

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      return { error: "Error de Moondream: #{response.code} - #{response.body}", confianza: 0 }
    end

    parsed = JSON.parse(response.body)
    parse_moondream_chat_response(parsed)
  rescue JSON::ParserError => e
    { error: "Error al parsear respuesta de Moondream: #{e.message}", confianza: 0 }
  rescue => e
    { error: "Error con Moondream: #{e.message}", confianza: 0 }
  end

  def analyze_with_openrouter(image_data)
    api_key = ENV["OPENROUTER_API_KEY"]

    if api_key.nil? || api_key.empty?
      return {
        error: "API key de OpenRouter no configurada. Contacta al administrador.",
        confianza: 0,
        necesita_config: true
      }
    end

    base64_image = prepare_image(image_data)
    prompt = "Eres un experto en antigüedades y objetos de segunda mano. Analiza esta imagen de un producto y proporciona una descripción detallada en español, categoría sugerida, tipo de producto, marca/modelo (si identificable), estado aparente (nuevo/bueno/aceptable/desgastado/para_restaurar), etiquetas sugeridas (en_venta/reservado/vendido/en_restauracion) y confianza del 0-100%. Responde SOLO en JSON con este formato exacto: {\"descripcion\":\"...\",\"categoria_sugerida\":\"...\",\"tipo_producto\":\"...\",\"marca_modelo\":\"...\",\"estado\":\"...\",\"etiqueta\":\"...\",\"confianza\":0-100}. No escribas nada más que el JSON."

    uri = URI(OPENROUTER_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 30
    http.read_timeout = 60

    OPENROUTER_MODELS.each do |model|
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request["Authorization"] = "Bearer #{api_key}"
      request.body = {
        model: model,
        max_tokens: 500,
        messages: [
          {
            role: "user",
            content: [
              { type: "text", text: prompt },
              { type: "image_url", image_url: { url: "data:image/jpeg;base64,#{base64_image}" } }
            ]
          }
        ],
        stream: false
      }.to_json

      begin
        response = http.request(request)
        parsed = JSON.parse(response.body)

        if response.is_a?(Net::HTTPSuccess)
          result = parse_openrouter_response(parsed)
          result["source"] = "openrouter"
          return result
        end

        if [ 429, 402, 400, 503 ].include?(response.code.to_i)
          next
        end

        error_msg = parsed.dig("error", "message") || "Error desconocido"
        return { error: "Error de OpenRouter (#{model}): #{response.code} - #{error_msg}", confianza: 0 }
      rescue StandardError => e
        next
      end
    end

    { error: "Todos los modelos de OpenRouter fallaron. Intenta más tarde o cambia el servicio de IA.", confianza: 0 }
  end

  def parse_openrouter_response(response)
    choices = response["choices"]
    return { error: "No se recibió respuesta de OpenRouter", confianza: 0 } unless choices && choices.any?

    message = choices[0]["message"]
    return { error: "No se recibió mensaje de OpenRouter", confianza: 0 } unless message

    content = message["content"]
    return { error: "No se recibió contenido de OpenRouter", confianza: 0 } unless content

    json_match = content.match(/\{.*\}/m)
    if json_match
      parsed = JSON.parse(json_match[0])
      return parsed.merge("source" => "openrouter")
    end

    {
      "descripcion" => content,
      "categoria_sugerida" => "General",
      "tipo_producto" => "Producto",
      "marca_modelo" => "",
      "estado" => "bueno",
      "etiqueta" => "en_venta",
      "confianza" => 75,
      "source" => "openrouter"
    }
  rescue JSON::ParserError => e
    { error: "Error al procesar respuesta de OpenRouter: #{e.message}", confianza: 0 }
  end

  def prepare_image(image_data)
    if image_data.is_a?(String)
      if image_data.start_with?("data:")
        image_data.split(",").last
      elsif image_data.start_with?("/")
        Base64.strict_encode64(File.read(image_data))
      else
        image_data
      end
    elsif image_data.respond_to?(:read)
      Base64.strict_encode64(image_data.read)
    else
      Base64.strict_encode64(image_data.to_s)
    end
  end

  def detect_mime_type(image_data)
    if image_data.is_a?(String) && image_data.start_with?("/9j")
      "image/jpeg"
    elsif image_data.is_a?(String) && image_data.start_with?("iVBOR")
      "image/png"
    elsif image_data.is_a?(String) && image_data.start_with?("UklGR")
      "image/webp"
    else
      "image/jpeg"
    end
  end

  def make_request(uri, request, retries: 3)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = 30
    http.read_timeout = 60

    response = http.request(request)
    raise "API Error: #{response.code} - #{response.body}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  rescue JSON::ParserError => e
    raise "Error al parsear respuesta: #{e.message}"
  end

  def parse_gemini_response(response)
    text = response.dig("candidates", 0, "content", "parts", 0, "text")
    return { error: "No se recibió respuesta de Gemini", confianza: 0 } unless text

    json_match = text.match(/\{.*\}/m)
    return { error: "Gemini no devolvió JSON válido", confianza: 0 } unless json_match

    JSON.parse(json_match[0]).merge(source: "gemini")
  rescue JSON::ParserError => e
    { error: "Error al parsear respuesta de Gemini: #{e.message}", confianza: 0, raw_response: text }
  end

  def parse_moondream_response(response)
    answer = response["answer"] || response["result"]
    return { error: "No se recibió respuesta de Moondream", confianza: 0 } unless answer

    json_match = answer.match(/\{.*\}/m)
    if json_match
      parsed = JSON.parse(json_match[0])
      return parsed.merge("source" => "moondream")
    end

    {
      "descripcion" => answer,
      "categoria_sugerida" => "General",
      "tipo_producto" => "Producto",
      "marca_modelo" => "",
      "estado" => "bueno",
      "etiqueta" => "en_venta",
      "confianza" => 75,
      "source" => "moondream"
    }
  rescue JSON::ParserError
    { error: "Error al procesar respuesta de Moondream", confianza: 0 }
  end

  def parse_moondream_chat_response(response)
    choices = response["choices"]
    return { error: "No se recibió respuesta de Moondream", confianza: 0 } unless choices && choices.any?

    message = choices[0]["message"]
    return { error: "No se recibió mensaje de Moondream", confianza: 0 } unless message

    content = message["content"]
    return { error: "No se recibió contenido de Moondream", confianza: 0 } unless content

    json_match = content.match(/\{.*\}/m)
    if json_match
      parsed = JSON.parse(json_match[0])
      return parsed.merge("source" => "moondream")
    end

    {
      "descripcion" => content,
      "categoria_sugerida" => "General",
      "tipo_producto" => "Producto",
      "marca_modelo" => "",
      "estado" => "bueno",
      "etiqueta" => "en_venta",
      "confianza" => 75,
      "source" => "moondream"
    }
  rescue JSON::ParserError => e
    { error: "Error al procesar respuesta de Moondream: #{e.message}", confianza: 0 }
  end
end

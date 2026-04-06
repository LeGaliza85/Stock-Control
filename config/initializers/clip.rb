 require "clip"

 Rails.logger.info "Pre-cargando modelo CLIP..."
 $clip_model = nil

 begin
   $clip_model = Clip::Model.new
   Rails.logger.info "Modelo CLIP cargado correctamente."
 rescue => e
   Rails.logger.warn "No se pudo pre-cargar CLIP: #{e.message}. Se cargará en el primer uso."
 end

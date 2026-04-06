module ApplicationHelper
  def formato_precio(precio)
    number_to_currency(precio, unit: "$", separator: ".", delimiter: ",", precision: 0)
  end

  def formato_codigo(codigo)
    return "" if codigo.blank?
    codigo.gsub(/([A-Za-z]+)(\d+)/, '\1 \2').gsub(/(\d+)([A-Za-z]+)/, '\1 \2')
  end

  def active_filters_count(params)
    [:categoria, :estado, :etiqueta].count { |k| params[k].present? } +
      (params[:vistos] == "true" ? 1 : 0)
  end
end

module ApplicationHelper
  def formato_precio(precio)
    number_to_currency(precio, unit: "$", separator: ".", delimiter: ",", precision: 0)
  end
end

module CurrencyHelper
  def currency_symbol(code)
    {
      "USD" => "$",
      "EUR" => "€",
      "CLP" => "$",
      "MXN" => "$",
      "ARS" => "$",
      "BRL" => "R$",
      "GBP" => "£"
    }[code] || code
  end
end

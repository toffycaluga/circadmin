module FormattedCountryName
  # tus métodos aquí...

  def formatted_country_name(code)
    match = country_options_with_flags.find { |_, value, _| value == code }
    match ? match[0] : code
  end
end

# db/seeds/plans.rb

# Define aquí tus planes; por ahora solo el “Basic”
# Más adelante podrás descomentar o añadir nuevos hashes para Ticketing, Concessions, All-in-One, etc.
plans = [
   {
    key:              'basic',
    stripe_price_id:  'price_BASIC',
    price_cents:      2_000,   # USD 20.00
    allowed_circuses: 1,
    trial_days:       30,      # 30 días de prueba, una sola vez por usuario
    active:           true
  }
  # Ejemplo de futuros módulos (descomentar cuando estén listos):
  # {
  #   key:              'ticketing',
  #   stripe_price_id:  'price_TICKETING',
  #   price_cents:      5_000,   # USD 50.00
  #   allowed_circuses: 1,
  #   trial_days:       30,
  #   active:           true
  # },
  # {
  #   key:              'concessions',
  #   stripe_price_id:  'price_CONCESSIONS',
  #   price_cents:      5_000,   # USD 50.00
  #   allowed_circuses: 1,
  #   trial_days:       30,
  #   active:           true
  # },
  # {
  #   key:              'all_in_one',
  #   stripe_price_id:  'price_ALL_IN_ONE',
  #   price_cents:      10_000,  # USD 100.00
  #   allowed_circuses: 3,
  #   trial_days:       30,
  #   active:           true
  # }
]

plans.each do |attrs|
  plan = Plan.find_or_initialize_by(stripe_price_id: attrs[:stripe_price_id])
  # Asignamos solo los atributos técnicos
  plan.assign_attributes(
    price_cents:      attrs[:price_cents],
    allowed_circuses: attrs[:allowed_circuses],
    trial_days:       attrs[:trial_days],
    active:           attrs[:active]
  )

  # Guardamos la key y un nombre por defecto (humanizado) para evitar NOT NULL
  plan.key  = attrs[:key]
  plan.name = attrs[:key].humanize

  plan.save!
end

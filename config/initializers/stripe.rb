# config/initializers/stripe.rb
require "stripe"



Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
# Usa Figaro o credenciales Rails para las keys
# Stripe.api_version = "2022-11-15" # opcional, fija la versión que usas

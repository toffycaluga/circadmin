# config/initializers/stripe.rb
require "stripe"



Stripe.api_key = ENV["STRIPE_SECRET_KEY"]
# Usa Figaro o credenciales Rails para las keys
Stripe.api_version = ENV["STRIPE_API_VERSION"] # opcional, fija la versión que usas

# lib/tasks/stripe_check.rake
namespace :stripe do
  desc "Verifica que todos los stripe_price_id de Plan existan en Stripe"
  task check_prices: :environment do
    require "stripe"
    Stripe.api_key = ENV["STRIPE_SECRET_KEY"]

    Plan.find_each do |p|
      begin
        price = Stripe::Price.retrieve(p.stripe_price_id)
        puts "[OK] #{p.key} -> #{price.id} (#{price.currency}/#{price.unit_amount})"
      rescue Stripe::InvalidRequestError => e
        puts "[ERR] #{p.key} -> #{p.stripe_price_id} no existe (#{e.message})"
      end
    end
  end
end

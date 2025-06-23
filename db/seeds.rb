# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

admin_email    = ENV.fetch("ADMIN_EMAIL")
admin_password = ENV.fetch("ADMIN_PASSWORD")

admin = User.find_or_initialize_by(email: admin_email)
if admin.new_record?
  admin.password              = admin_password
  admin.password_confirmation = admin_password
  admin.superadmin            = true
  # admin.confirmed_at = Time.current if admin.respond_to?(:confirmed_at)
  admin.save!
  puts "✅ Superadmin creado: #{admin.email}"
else
  puts "ℹ️ Superadmin ya existe: #{admin.email}"
end

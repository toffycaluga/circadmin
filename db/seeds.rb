# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Borrando datos antiguos..."
CircusUser.destroy_all
Circus.destroy_all
User.destroy_all

puts "Creando usuario dueño..."
owner = User.create!(
  email: "admin@circadmin.com",
  password: "password123",
  password_confirmation: "password123"
)

# puts "Creando circo..."
# circus = Circus.create!(
#   name: "Circo Fantástico",
#   country: "Chile",
#   currency: "CLP",
#   active: true
# )

# puts "Asociando dueño con el circo..."
# CircusUser.create!(
#   user: owner,
#   circus: circus
# )

puts "Seed finalizado correctamente! ✅"

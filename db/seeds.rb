# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
User.find_or_create_by!(email: "grupobothi@mailinator.com") do |user|
  user.assign_attributes(
    first_name: "Jacinto",
    last_name: "Bothi",
    second_last_name: "Cruz",
    phone: "+525512345678",
    password: "GrupoBothi12345*",
    password_confirmation: "GrupoBothi12345*",
    active: true,
    role: :super_admin,
  )
end

puts "Super admin creado/actualizado exitosamente!"
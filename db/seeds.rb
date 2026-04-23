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


# ─────────────────────────────────────────
# UNITS
# ─────────────────────────────────────────
units_data = [
  { key: "pza",  name: "Pieza",       group: "cantidad", position: 1 },
  { key: "hr",   name: "Hora",        group: "tiempo",   position: 2 },
  { key: "kg",   name: "Kilogramo",   group: "peso",     position: 3 },
  { key: "lt",   name: "Litro",       group: "volumen",  position: 4 },
  { key: "mts",  name: "Metro",       group: "longitud", position: 5 },
  { key: "serv", name: "Servicio",    group: "servicio", position: 6 },
]
units_data.each do |data|
  Unit.find_or_create_by!(key: data[:key]) do |u|
    u.assign_attributes(name: data[:name], group: data[:group], position: data[:position])
  end
end
puts "  [ok] #{units_data.size} units"

# ─────────────────────────────────────────
# COMPANIES CON TRIAL ESPECIAL (para pruebas)
# ─────────────────────────────────────────

# Empresa 1: trial que vence en 2 días
company_expiring = Company.find_or_create_by!(slug: "trial-expirando") do |c|
  c.name = "Trial Expirando"
  c.plan = :starter
end
company_expiring.subscription&.update!(
  status: :trialing,
  trial_ends_at: 2.days.from_now
)

user_expiring = User.find_or_create_by!(email: "admin-expirando@test.com") do |u|
  u.assign_attributes(
    first_name: "Admin",
    last_name: "Expirando",
    second_last_name: "Test",
    phone: "+521111111111",
    password: "Test12345*",
    password_confirmation: "Test12345*",
    active: true,
    role: :admin
  )
end
UserCompany.find_or_create_by!(user: user_expiring, company: company_expiring)
puts "  [ok] admin-expirando@test.com — trial vence en 2 días (#{company_expiring.subscription.trial_ends_at.to_date})"

# Empresa 2: trial ya vencido
company_expired = Company.find_or_create_by!(slug: "trial-vencido") do |c|
  c.name = "Trial Vencido"
  c.plan = :starter
end
company_expired.subscription&.update!(
  status: :expired,
  trial_ends_at: 5.days.ago
)

user_expired = User.find_or_create_by!(email: "admin-vencido@test.com") do |u|
  u.assign_attributes(
    first_name: "Admin",
    last_name: "Vencido",
    second_last_name: "Test",
    phone: "+522222222222",
    password: "Test12345*",
    password_confirmation: "Test12345*",
    active: true,
    role: :admin
  )
end
UserCompany.find_or_create_by!(user: user_expired, company: company_expired)
puts "  [ok] admin-vencido@test.com — trial vencido desde #{company_expired.subscription.trial_ends_at.to_date}"
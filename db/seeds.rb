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
    role: :admin,
  )
end

puts "Super admin creado/actualizado exitosamente!"

# =============================================================================
# EMPRESA: Material Eléctrico
# =============================================================================

company = Company.find_or_create_by!(slug: "electricos-bothi") do |c|
  c.name = "Eléctricos Bothi"
  c.plan = :business
end

puts "Empresa '#{company.name}' lista."

# Asignar empresa al super admin si aún no tiene
admin = User.find_by(email: "grupobothi@mailinator.com")
admin.update!(company: company) if admin && admin.company_id.nil?

# Crear usuario owner de la empresa
owner = User.find_or_create_by!(email: "owner@electricosbothi.com") do |u|
  u.assign_attributes(
    first_name:       "Carlos",
    last_name:        "Ramírez",
    second_last_name: "Torres",
    phone:            "+525598765432",
    password:         "GrupoBothi12345*",
    password_confirmation: "GrupoBothi12345*",
    active:           true,
    role:             :owner,
    company:          company
  )
end

puts "Owner '#{owner.first_name}' listo."

# =============================================================================
# PRODUCTOS — Material Eléctrico
# =============================================================================

products_data = [
  { sku: "CAB-THW-12",  name: "Cable THW calibre 12 AWG (rollo 100m)", min_stock: 5,  unit_cost: 450.00, entrada: 20, salida: 4  },
  { sku: "CAB-THW-14",  name: "Cable THW calibre 14 AWG (rollo 100m)", min_stock: 5,  unit_cost: 340.00, entrada: 15, salida: 3  },
  { sku: "CAB-CAL-10",  name: "Cable calibre 10 AWG (rollo 50m)",      min_stock: 3,  unit_cost: 580.00, entrada: 10, salida: 2  },
  { sku: "TUB-PVC-12",  name: "Tubo conduit PVC 1/2\" (tramo 3m)",     min_stock: 20, unit_cost: 22.00,  entrada: 100, salida: 25 },
  { sku: "TUB-PVC-34",  name: "Tubo conduit PVC 3/4\" (tramo 3m)",     min_stock: 15, unit_cost: 32.00,  entrada: 80,  salida: 18 },
  { sku: "INT-SEN-01",  name: "Interruptor sencillo",                  min_stock: 10, unit_cost: 45.00,  entrada: 50,  salida: 12 },
  { sku: "INT-DOB-01",  name: "Interruptor doble",                     min_stock: 8,  unit_cost: 75.00,  entrada: 30,  salida: 5  },
  { sku: "CON-DUP-01",  name: "Contacto duplex polarizado",            min_stock: 10, unit_cost: 55.00,  entrada: 60,  salida: 15 },
  { sku: "CAJ-4X4-01",  name: "Caja de registro 4x4",                  min_stock: 20, unit_cost: 18.00,  entrada: 120, salida: 30 },
  { sku: "CAJ-2X4-01",  name: "Caja de registro 2x4",                  min_stock: 20, unit_cost: 12.00,  entrada: 150, salida: 40 },
  { sku: "BRK-1X20-01", name: "Breaker 1x20A",                         min_stock: 5,  unit_cost: 120.00, entrada: 25,  salida: 6  },
  { sku: "BRK-1X15-01", name: "Breaker 1x15A",                         min_stock: 5,  unit_cost: 110.00, entrada: 25,  salida: 8  },
  { sku: "PAN-8C-01",   name: "Panel de distribución 8 circuitos",     min_stock: 2,  unit_cost: 650.00, entrada: 8,   salida: 1  },
  { sku: "FOC-LED-18",  name: "Foco LED 18W",                          min_stock: 10, unit_cost: 85.00,  entrada: 80,  salida: 20 },
  { sku: "CIN-AIS-01",  name: "Cinta aislante negra (rollo)",          min_stock: 10, unit_cost: 15.00,  entrada: 60,  salida: 14 },
]

products_data.each do |data|
  product = company.products.find_or_create_by!(sku: data[:sku]) do |p|
    p.name      = data[:name]
    p.min_stock = data[:min_stock]
    p.unit_cost = data[:unit_cost]
    p.stock     = 0
  end

  # Solo crear movimientos si el producto no tiene ninguno (idempotente)
  next if product.stock_movements.exists?

  product.stock_movements.create!(
    company:       company,
    movement_type: :entry,
    qty:           data[:entrada],
    note:          "Inventario inicial"
  )

  product.stock_movements.create!(
    company:       company,
    movement_type: :exit,
    qty:           data[:salida],
    note:          "Salida a obra — instalación eléctrica"
  )

  puts "  #{product.sku} | #{product.reload.stock} uds en stock"
end

puts "Inventario de material eléctrico cargado exitosamente!"

# =============================================================================
# EMPLEADOS — Eléctricos Bothi
# =============================================================================

employees_data = [
  { name: "Miguel Ángel Herrera Juárez",  position: "Electricista maestro",     department: "Operaciones", salary: 18_500.00 },
  { name: "Roberto Sánchez Mendoza",      position: "Electricista oficial",      department: "Operaciones", salary: 14_000.00 },
  { name: "Luis Fernando Pérez Castro",   position: "Electricista oficial",      department: "Operaciones", salary: 14_000.00 },
  { name: "Jesús Antonio Morales Ruiz",   position: "Ayudante de electricista",  department: "Operaciones", salary: 9_500.00  },
  { name: "Eduardo Ramírez Flores",       position: "Ayudante de electricista",  department: "Operaciones", salary: 9_500.00  },
  { name: "Ana Laura Torres Vega",        position: "Encargada de almacén",      department: "Almacén",     salary: 12_000.00 },
  { name: "Diego Martínez López",         position: "Auxiliar de almacén",       department: "Almacén",     salary: 9_000.00  },
  { name: "Patricia González Ortiz",      position: "Vendedora",                 department: "Ventas",      salary: 11_000.00 },
  { name: "Jorge Alberto Díaz Reyes",     position: "Vendedor",                  department: "Ventas",      salary: 11_000.00 },
  { name: "Sandra Ivonne Ríos Salinas",   position: "Administradora",            department: "Administración", salary: 16_000.00 },
]

employees_data.each do |data|
  employee = company.employees.find_or_create_by!(name: data[:name]) do |e|
    e.position   = data[:position]
    e.department = data[:department]
    e.salary     = data[:salary]
    e.status     = :active
  end

  puts "  #{employee.name} — #{employee.position}"
end

puts "Empleados cargados exitosamente (#{employees_data.size} empleados)!"

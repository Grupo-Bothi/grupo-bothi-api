class AddProductAndTotalToWorkOrders < ActiveRecord::Migration[8.0]
  def change
    # Cada item puede referenciar un producto del inventario
    add_reference :work_order_items, :product, foreign_key: true, null: true
    # Precio unitario capturado al momento de agregar el item
    add_column :work_order_items, :unit_price, :decimal, precision: 10, scale: 2

    # Total acumulado de todos los items con precio en la orden
    add_column :work_orders, :total, :decimal, precision: 10, scale: 2, default: 0, null: false
  end
end

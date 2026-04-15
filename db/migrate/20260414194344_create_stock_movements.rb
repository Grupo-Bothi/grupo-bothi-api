class CreateStockMovements < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_movements do |t|
      t.references :product, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.integer :movement_type
      t.integer :qty
      t.string :note

      t.timestamps
    end
  end
end

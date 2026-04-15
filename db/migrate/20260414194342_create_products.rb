class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.references :company, null: false, foreign_key: true
      t.string :sku
      t.string :name
      t.integer :stock
      t.integer :min_stock
      t.decimal :unit_cost

      t.timestamps
    end
  end
end

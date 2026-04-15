class CreateWorkOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :work_order_items do |t|
      t.references :work_order, null: false, foreign_key: true
      t.string :description
      t.decimal :quantity
      t.string :unit
      t.integer :status
      t.integer :position
      t.datetime :completed_at

      t.timestamps
    end
  end
end

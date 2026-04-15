class CreateWorkOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :work_orders do |t|
      t.references :company, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true 
      t.references :created_by, polymorphic: true, null: false
      t.string :title
      t.text :description
      t.integer :priority
      t.integer :status
      t.datetime :due_date
      t.datetime :completed_at
      t.text :notes
      t.timestamps
    end
    add_index :work_orders, [:created_by_type, :created_by_id]
  end
end

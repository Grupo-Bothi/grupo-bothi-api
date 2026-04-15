class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name
      t.string :position
      t.string :department
      t.decimal :salary
      t.integer :status

      t.timestamps
    end
  end
end

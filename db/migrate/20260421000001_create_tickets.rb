class CreateTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :tickets do |t|
      t.belongs_to :work_order, null: false, foreign_key: true, index: { unique: true }
      t.belongs_to :company, null: false, foreign_key: true
      t.string  :folio, null: false
      t.integer :status, null: false, default: 0
      t.decimal :total, precision: 10, scale: 2, null: false, default: "0.0"
      t.datetime :paid_at
      t.text :notes
      t.timestamps
    end

    add_index :tickets, :folio, unique: true
    add_index :tickets, :status
  end
end

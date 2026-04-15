class CreateAttendances < ActiveRecord::Migration[8.0]
  def change
    create_table :attendances do |t|
      t.references :employee, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.datetime :checkin_at
      t.datetime :checkout_at
      t.decimal :lat
      t.decimal :lng
      t.integer :attendance_type

      t.timestamps
    end
  end
end

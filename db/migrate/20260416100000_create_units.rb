class CreateUnits < ActiveRecord::Migration[8.0]
  def change
    create_table :units do |t|
      t.string  :key,      null: false
      t.string  :name,     null: false
      t.string  :group,    null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :units, :key,   unique: true
    add_index :units, :group
  end
end

class AddContactToEmployees < ActiveRecord::Migration[8.0]
  def change
    add_column :employees, :email, :string
    add_column :employees, :phone, :string
    add_index :employees, :email, unique: true, where: "email IS NOT NULL"
  end
end

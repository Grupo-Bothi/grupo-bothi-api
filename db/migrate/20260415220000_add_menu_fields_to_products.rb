class AddMenuFieldsToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :price,       :decimal, precision: 10, scale: 2
    add_column :products, :category,    :string
    add_column :products, :description, :text
    add_column :products, :available,   :boolean, default: true, null: false

    add_index :products, :category
    add_index :products, :available
  end
end

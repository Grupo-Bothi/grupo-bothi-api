class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :slug
      t.integer :plan
      t.string :stripe_id

      t.timestamps
    end
  end
end

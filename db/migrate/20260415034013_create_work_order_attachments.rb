class CreateWorkOrderAttachments < ActiveRecord::Migration[8.0]
  def change
    create_table :work_order_attachments do |t|
      t.references :work_order, null: false, foreign_key: true
      t.references :uploaded_by, polymorphic: true, null: false
      t.string :description

      t.timestamps
    end
  end
end

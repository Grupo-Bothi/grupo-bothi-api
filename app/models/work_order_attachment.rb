# app/models/work_order_attachment.rb
class WorkOrderAttachment < ApplicationRecord
  belongs_to :work_order
  belongs_to :uploaded_by, polymorphic: true
  has_one_attached :file

  validates :file, presence: true
end
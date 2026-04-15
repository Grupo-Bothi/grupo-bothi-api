# app/models/work_order_item.rb
class WorkOrderItem < ApplicationRecord
  belongs_to :work_order
  belongs_to :product, optional: true

  enum :status, { pending: 0, completed: 1 }, default: :pending

  validates :description, presence: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }

  before_validation :inherit_product_defaults, if: :product_id_changed?

  after_save    :recalculate_order_total
  after_destroy :recalculate_order_total
  after_update  :sync_parent_status, if: :saved_change_to_status?

  def subtotal
    return 0 if unit_price.nil? || quantity.nil?
    (unit_price * quantity).round(2)
  end

  private

  # Rellena descripción y precio desde el producto si no se proveyeron
  def inherit_product_defaults
    return unless product
    self.description ||= product.name
    self.unit_price  ||= product.price
  end

  def recalculate_order_total
    work_order.recalculate_total!
  end

  def sync_parent_status
    work_order.sync_status!
  end
end
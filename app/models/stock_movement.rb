# app/models/stock_movement.rb
class StockMovement < ApplicationRecord
  belongs_to :product
  belongs_to :company

  enum :movement_type, { entry: 0, exit: 1, adjustment: 2 }

  validates :qty, presence: true, numericality: { other_than: 0 }

  scope :search, ->(q) {
    joins(:product).where("products.name ILIKE :q OR stock_movements.note ILIKE :q", q: "%#{q}%") if q.present?
  }

  after_create :update_stock

  private

  def update_stock
    delta = movement_type == 'exit' ? -qty.abs : qty.abs
    product.increment!(:stock, delta)
  end
end
# app/models/product.rb
class Product < ApplicationRecord
  belongs_to :company
  has_many :stock_movements

  validates :name, :sku, presence: true
  validates :sku, uniqueness: { scope: :company_id }
  validates :stock, numericality: { greater_than_or_equal_to: 0 }

  scope :search, ->(q) {
    where("name ILIKE :q OR sku ILIKE :q", q: "%#{q}%") if q.present?
  }
end
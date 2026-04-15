# app/models/company.rb
class Company < ApplicationRecord
  has_many :users
  has_many :employees
  has_many :products
  has_many :stock_movements

  enum :plan, { starter: 0, business: 1, enterprise: 2 }, default: :starter

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, on: :create

  private

  def generate_slug
    self.slug ||= name.to_s.downcase.gsub(/\s+/, '-').gsub(/[^a-z0-9-]/, '')
  end
end
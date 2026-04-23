# app/models/company.rb
class Company < ApplicationRecord
  has_many :user_companies, dependent: :destroy
  has_many :users, through: :user_companies
  has_many :attendances, dependent: :destroy
  has_many :employees, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :stock_movements, dependent: :destroy
  has_many :work_orders, dependent: :destroy
  has_many :tickets, dependent: :destroy
  has_one :subscription, dependent: :destroy

  enum :plan, { starter: 0, business: 1, enterprise: 2 }, default: :starter

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, on: :create
  after_create :create_trial_subscription

  private

  def generate_slug
    self.slug ||= name.to_s.downcase.gsub(/\s+/, '-').gsub(/[^a-z0-9-]/, '')
  end

  def create_trial_subscription
    Subscription.start_trial!(self)
  end
end
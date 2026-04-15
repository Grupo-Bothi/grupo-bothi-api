# app/models/employee.rb
class Employee < ApplicationRecord
  belongs_to :company
  has_many :attendances

  enum :status, { active: 0, inactive: 1 }, default: :active

  validates :name, presence: true

  scope :search, ->(q) {
    where("name ILIKE :q OR position ILIKE :q OR department ILIKE :q", q: "%#{q}%") if q.present?
  }
end
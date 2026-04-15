# app/models/unit.rb
class Unit < ApplicationRecord
  validates :key,  presence: true, uniqueness: true
  validates :name, presence: true
  validates :group, presence: true

  scope :ordered, -> { order(:group, :position, :key) }
end

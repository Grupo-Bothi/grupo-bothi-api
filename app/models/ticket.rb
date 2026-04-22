# app/models/ticket.rb
class Ticket < ApplicationRecord
  belongs_to :work_order
  belongs_to :company

  enum :status, { pending: 0, paid: 1 }, default: :pending

  validates :folio, presence: true, uniqueness: true
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :reserve_folio, on: :create  # runs before validations so presence check passes
  before_create     :copy_total
  after_create      :assign_folio                 # replaces temp value with ID-based folio

  private

  def copy_total
    self.total = work_order.total
  end

  def reserve_folio
    self.folio = "T-#{SecureRandom.hex(8)}"
  end

  def assign_folio
    update_column(:folio, format("T-%06d", id))
  end
end

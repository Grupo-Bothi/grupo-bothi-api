# app/models/work_order.rb
class WorkOrder < ApplicationRecord
  belongs_to :company
  belongs_to :employee, optional: true
  belongs_to :created_by, polymorphic: true
  has_many   :work_order_items, -> { order(:position) }, dependent: :destroy
  has_many   :products, through: :work_order_items
  has_many_attached :attachments
  has_one    :ticket, dependent: :destroy

  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }, default: :medium
  enum :status, {
    pending:     0,
    in_progress: 1,
    in_review:   2,
    completed:   3,
    cancelled:   4
  }, default: :pending

  scope :search, ->(q) {
    return all unless q.present?
    where("title ILIKE :q OR description ILIKE :q", q: "%#{q}%")
  }

  validates :title, presence: true

  after_commit :generate_ticket!, if: -> {
    previous_changes["status"]&.last == "completed" && ticket.nil?
  }

  # Checklist progress
  def progress
    return 0 if work_order_items.none?
    done = work_order_items.where(status: :completed).count
    total = work_order_items.count
    (done.to_f / total * 100).round
  end

  # Auto-complete cuando todos los items están listos
  def sync_status!
    return if cancelled?
    return unless work_order_items.any?
    if work_order_items.all?(&:completed?)
      update!(status: :in_review, completed_at: nil)
    end
  end

  private

  def generate_ticket!
    Ticket.create!(work_order: self, company: company)
  rescue => e
    Rails.logger.error "Ticket generation failed for WorkOrder##{id}: #{e.message}"
  end

  public

  # Suma los subtotales (unit_price * quantity) de todos los items que tengan precio
  def recalculate_total!
    new_total = work_order_items.reload.sum(&:subtotal)
    update_column(:total, new_total)
  end
end
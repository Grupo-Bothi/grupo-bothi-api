class Subscription < ApplicationRecord
  belongs_to :company

  TRIAL_DAYS = 30
  IVA_RATE = 0.16

  # amount_cents es el precio base SIN IVA, en centavos de MXN
  PRICING = {
    "business" => {
      billing_cycle: "monthly",
      amount_cents: 70_000,
      stripe_price_id: ENV.fetch("STRIPE_BUSINESS_MONTHLY_PRICE_ID", nil)
    },
    "enterprise" => {
      billing_cycle: "annual",
      amount_cents: Integer(ENV.fetch("ENTERPRISE_AMOUNT_CENTS", "756000")),
      stripe_price_id: ENV.fetch("STRIPE_ENTERPRISE_ANNUAL_PRICE_ID", nil)
    }
  }.freeze

  enum :plan, { starter: 0, business: 1, enterprise: 2 }
  enum :status, { trialing: 0, active: 1, past_due: 2, cancelled: 3, expired: 4 }
  enum :billing_cycle, { monthly: 0, annual: 1 }

  validates :plan, :status, :billing_cycle, presence: true

  def self.start_trial!(company)
    create!(
      company: company,
      plan: :starter,
      status: :trialing,
      billing_cycle: :monthly,
      amount_cents: 0,
      trial_ends_at: TRIAL_DAYS.days.from_now
    )
  end

  def active_access?
    (trialing? && trial_ends_at&.future?) || active? || past_due?
  end

  def trial_days_remaining
    return 0 unless trialing? && trial_ends_at
    [ (trial_ends_at.to_date - Date.current).to_i, 0 ].max
  end

  def amount
    amount_cents / 100.0
  end

  def iva_amount
    (amount_cents * IVA_RATE / 100.0).round(2)
  end

  def total_with_iva
    (amount_cents * (1 + IVA_RATE) / 100.0).round(2)
  end
end

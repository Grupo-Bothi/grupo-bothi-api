class SubscriptionSerializer
  def initialize(subscription)
    @s = subscription
  end

  def as_json
    return { plan: "starter", status: "expired", active_access: false } if @s.nil?

    {
      id: @s.id,
      plan: @s.plan,
      status: @s.status,
      billing_cycle: @s.billing_cycle,
      amount: @s.amount,
      iva_amount: @s.iva_amount,
      total_with_iva: @s.total_with_iva,
      iva_rate: Subscription::IVA_RATE,
      trial_ends_at: @s.trial_ends_at,
      trial_days_remaining: @s.trial_days_remaining,
      current_period_start: @s.current_period_start,
      current_period_end: @s.current_period_end,
      active_access: @s.active_access?,
      cancelled_at: @s.cancelled_at,
      created_at: @s.created_at
    }
  end
end

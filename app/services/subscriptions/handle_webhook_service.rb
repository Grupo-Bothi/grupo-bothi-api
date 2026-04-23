module Subscriptions
  class HandleWebhookService
    def initialize(event)
      @event = event
    end

    def call
      case @event.type
      when "checkout.session.completed"
        handle_checkout_completed(@event.data.object)
      when "customer.subscription.updated"
        handle_subscription_updated(@event.data.object)
      when "customer.subscription.deleted"
        handle_subscription_deleted(@event.data.object)
      when "invoice.payment_failed"
        handle_payment_failed(@event.data.object)
      when "invoice.paid"
        handle_invoice_paid(@event.data.object)
      end
    end

    private

    def handle_checkout_completed(session)
      company = Company.find_by(id: session.metadata["company_id"])
      return unless company

      plan        = session.metadata["plan"]
      stripe_sub  = Stripe::Subscription.retrieve(session.subscription)
      pricing     = Subscription::PRICING[plan]

      subscription = company.subscription || company.build_subscription
      subscription.update!(
        plan: plan,
        status: :active,
        stripe_subscription_id: stripe_sub.id,
        billing_cycle: pricing[:billing_cycle],
        amount_cents: pricing[:amount_cents],
        current_period_start: Time.zone.at(stripe_sub.current_period_start),
        current_period_end: Time.zone.at(stripe_sub.current_period_end),
        trial_ends_at: nil,
        cancelled_at: nil
      )
      company.update_column(:plan, Company.plans[plan])
    end

    def handle_subscription_updated(stripe_sub)
      subscription = Subscription.find_by(stripe_subscription_id: stripe_sub.id)
      return unless subscription

      subscription.update!(
        status: map_stripe_status(stripe_sub.status),
        current_period_start: Time.zone.at(stripe_sub.current_period_start),
        current_period_end: Time.zone.at(stripe_sub.current_period_end)
      )
    end

    def handle_subscription_deleted(stripe_sub)
      subscription = Subscription.find_by(stripe_subscription_id: stripe_sub.id)
      return unless subscription

      subscription.update!(status: :cancelled, cancelled_at: Time.current)
      subscription.company.update_column(:plan, Company.plans[:starter])
    end

    def handle_payment_failed(invoice)
      return unless invoice.subscription

      subscription = Subscription.find_by(stripe_subscription_id: invoice.subscription)
      subscription&.update!(status: :past_due)
    end

    def handle_invoice_paid(invoice)
      return unless invoice.subscription

      subscription = Subscription.find_by(stripe_subscription_id: invoice.subscription)
      subscription&.update!(status: :active) if subscription&.past_due?
    end

    def map_stripe_status(stripe_status)
      case stripe_status
      when "active"   then :active
      when "past_due" then :past_due
      when "canceled" then :cancelled
      else :expired
      end
    end
  end
end

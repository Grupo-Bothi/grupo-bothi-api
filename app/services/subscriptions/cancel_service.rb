module Subscriptions
  class CancelService
    def initialize(subscription)
      @subscription = subscription
    end

    def call
      if @subscription.stripe_subscription_id.present?
        Stripe::Subscription.cancel(@subscription.stripe_subscription_id)
      end

      @subscription.update!(status: :cancelled, cancelled_at: Time.current)
      @subscription.company.update_column(:plan, Company.plans[:starter])
    end
  end
end

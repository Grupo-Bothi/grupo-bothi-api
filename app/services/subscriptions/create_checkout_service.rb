module Subscriptions
  class CreateCheckoutService
    def initialize(company:, plan:, success_url:, cancel_url:)
      @company     = company
      @plan        = plan.to_s
      @success_url = success_url
      @cancel_url  = cancel_url
    end

    def call
      pricing = Subscription::PRICING[@plan]
      raise ApiErrors::BadRequestError.new(details: I18n.t("errors.subscription.invalid_plan")) unless pricing
      raise ApiErrors::BadRequestError.new(details: I18n.t("errors.subscription.stripe_not_configured")) if pricing[:stripe_price_id].blank?

      customer_id = find_or_create_stripe_customer

      session = Stripe::Checkout::Session.create(
        customer: customer_id,
        mode: "subscription",
        line_items: [ { price: pricing[:stripe_price_id], quantity: 1 } ],
        success_url: @success_url,
        cancel_url: @cancel_url,
        metadata: { company_id: @company.id, plan: @plan },
        tax_id_collection: { enabled: true },
        automatic_tax: { enabled: false }
      )

      { checkout_url: session.url }
    end

    private

    def find_or_create_stripe_customer
      if @company.stripe_id.present?
        @company.stripe_id
      else
        customer = Stripe::Customer.create(
          name: @company.name,
          metadata: { company_id: @company.id, slug: @company.slug }
        )
        @company.update_column(:stripe_id, customer.id)
        customer.id
      end
    end
  end
end

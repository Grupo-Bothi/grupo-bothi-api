module Api
  module V1
    class StripeWebhooksController < ApplicationController
      WEBHOOK_SECRET = ENV.fetch("STRIPE_WEBHOOK_SECRET", nil)

      def create
        payload    = request.body.read
        sig_header = request.env["HTTP_STRIPE_SIGNATURE"]

        event = if WEBHOOK_SECRET.present?
          Stripe::Webhook.construct_event(payload, sig_header, WEBHOOK_SECRET)
        else
          Stripe::Event.construct_from(JSON.parse(payload))
        end

        Subscriptions::HandleWebhookService.new(event).call
        render json: { received: true }
      rescue JSON::ParserError
        render json: { error: "Invalid payload" }, status: :bad_request
      rescue Stripe::SignatureVerificationError
        render json: { error: "Invalid signature" }, status: :bad_request
      end
    end
  end
end

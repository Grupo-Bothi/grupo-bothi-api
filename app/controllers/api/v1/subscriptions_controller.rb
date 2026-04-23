module Api
  module V1
    class SubscriptionsController < BaseController
      skip_before_action :check_subscription!

      before_action :require_admin_or_owner!

      def show
        render json: SubscriptionSerializer.new(current_company.subscription).as_json
      end

      def checkout
        result = Subscriptions::CreateCheckoutService.new(
          company: current_company,
          plan: params.require(:plan),
          success_url: params.require(:success_url),
          cancel_url: params.require(:cancel_url)
        ).call

        render json: result, status: :ok
      end

      def cancel
        subscription = current_company.subscription
        raise ApiErrors::NotFoundError unless subscription&.active?

        Subscriptions::CancelService.new(subscription).call
        render json: SubscriptionSerializer.new(subscription.reload).as_json
      end

      private

      def require_admin_or_owner!
        return if current_user.admin? || current_user.owner? || current_user.super_admin?

        raise ApiErrors::ForbiddenError
      end
    end
  end
end

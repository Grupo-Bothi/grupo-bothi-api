module Subscriptions
  class CheckExpiredJob < ApplicationJob
    queue_as :default

    def perform
      Subscription.where(status: :trialing)
                  .where("trial_ends_at < ?", Time.current)
                  .update_all(status: Subscription.statuses[:expired])
    end
  end
end

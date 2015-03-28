require "clockwork"
require "./config/boot"
require "./config/environment"

module Clockwork
  every(1.day, "InvoiceChargeWorker") do
    Invoice.past_due.pluck(:id).each do |invoice_id|
      InvoiceChargeWorker.perform_async(invoice_id)
    end
  end

  every(1.hour, "OmniAuthTokenRefreshWorker") do
    # TODO: Limit to expired tokens. Need to look up how to query #auth_data jsonb column.
    OmniAuthProvider.where.not(name: "facebook").pluck(:id).each do |provider_id|
      OmniAuthTokenRefreshWorker.perform_async(provider_id)
    end
  end

  every(1.day, "SubscriptionUpdateWorker") do
    Subscription.where("current_period_end <= ?", Time.now).pluck(:id).each do |subscription_id|
      SubscriptionUpdateWorker.perform_async(subscription_id)
    end
  end
end

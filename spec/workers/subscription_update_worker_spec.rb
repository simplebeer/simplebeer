require "rails_helper"
Sidekiq::Testing.inline!

describe SubscriptionUpdateWorker, "#perform(subscription_id)" do

  before(:each) do
    stub_request(:post, "https://api.stripe.com/v1/customers").to_return(
      body: File.read(File.join(Rails.root, "spec/web_mock/stripe_customer.json"))
    )
    stub_request(:get, "https://api.stripe.com/v1/customers/cus_4paKHGMWyPEkmv").to_return(
      body: File.read(File.join(Rails.root, "spec/web_mock/stripe_customer.json"))
    )
    stub_request(:get, "https://api.stripe.com/v1/customers/cus_4paKHGMWyPEkmv/cards/card123").to_return(
      body: File.read(File.join(Rails.root, "spec/web_mock/stripe_card.json"))
    )
    @end_time = Time.now - 1.day
  end

  context "Active Auto-Renewing Subscription" do
    before(:each) do
      @subscription = create(:subscription, current_period_end: @end_time, payment_method: create(:stripe_card))
    end

    it "should update the current period start and end upon successful charge" do
      stub_request(:post, "https://api.stripe.com/v1/charges").to_return(
        body: File.read(File.join(Rails.root, "spec/web_mock/stripe_card_charge.json"))
      )

      period_start = @subscription.next_period_start
      period_end   = @subscription.next_period_end

      SubscriptionUpdateWorker.perform_async(@subscription.id)
      @subscription.reload

      expect(@subscription.subscriber.time.at(@subscription.current_period_start)).to be_within(100).of(period_start)
      expect(@subscription.subscriber.time.at(@subscription.current_period_end)).to   be_within(100).of(period_end)
    end

    it "should set the subscription status to :active upon successful charge" do
      stub_request(:post, "https://api.stripe.com/v1/charges").to_return(
        body: File.read(File.join(Rails.root, "spec/web_mock/stripe_card_charge.json"))
      )

      SubscriptionUpdateWorker.perform_async(@subscription.id)
      @subscription.reload

      expect(@subscription.active?).to eq(true)
    end

    it "should not update the current period start and end if the charge fails" do
      stub_request(:post, "https://api.stripe.com/v1/charges").to_return(
        body:   File.read(File.join(Rails.root, "spec/web_mock/stripe_card_charge_fail.json")),
        status: 402
      )

      period_start = @subscription.current_period_start
      period_end   = @subscription.current_period_end

      SubscriptionUpdateWorker.perform_async(@subscription.id)
      @subscription.reload

      expect(@subscription.current_period_start).to be_within(100).of(period_start)
      expect(@subscription.current_period_end).to   be_within(100).of(period_end)
    end

    it "should set the subscription status to :past_due if the charge fails" do
      stub_request(:post, "https://api.stripe.com/v1/charges").to_return(
        body:   File.read(File.join(Rails.root, "spec/web_mock/stripe_card_charge_fail.json")),
        status: 402
      )

      SubscriptionUpdateWorker.perform_async(@subscription.id)
      @subscription.reload

      expect(@subscription.past_due?).to eq(true)
    end

    it "should set the subscription status to :unpaid if the charge fails 3 times" do
      stub_request(:post, "https://api.stripe.com/v1/charges").to_return(
        body:   File.read(File.join(Rails.root, "spec/web_mock/stripe_card_charge_fail.json")),
        status: 402
      )

      SubscriptionUpdateWorker.perform_async(@subscription.id)
      SubscriptionUpdateWorker.perform_async(@subscription.id)
      SubscriptionUpdateWorker.perform_async(@subscription.id)
      @subscription.reload

      expect(@subscription.unpaid?).to eq(true)
    end
  end

  context "Trial Auto-Renewing Subscription" do
    before(:each) do
      @subscription = create(:trial_subscription, current_period_end: @end_time, trial_ends_at: @end_time, payment_method: create(:stripe_card))
    end

    it "should update the current period start and end upon successful charge" do
      stub_request(:post, "https://api.stripe.com/v1/charges").to_return(
        body: File.read(File.join(Rails.root, "spec/web_mock/stripe_card_charge.json"))
      )

      period_start = @subscription.next_period_start
      period_end   = @subscription.next_period_end

      SubscriptionUpdateWorker.perform_async(@subscription.id)
      @subscription.reload

      expect(@subscription.subscriber.time.at(@subscription.current_period_start)).to be_within(100).of(period_start)
      expect(@subscription.subscriber.time.at(@subscription.current_period_end)).to   be_within(100).of(period_end)
    end

    it "should set the subscription status to :active upon successful charge" do
      stub_request(:post, "https://api.stripe.com/v1/charges").to_return(
        body: File.read(File.join(Rails.root, "spec/web_mock/stripe_card_charge.json"))
      )

      SubscriptionUpdateWorker.perform_async(@subscription.id)
      @subscription.reload

      expect(@subscription.active?).to eq(true)
    end

    it "should not update the current period start and end if the charge fails" do
      stub_request(:post, "https://api.stripe.com/v1/charges").to_return(
        body:   File.read(File.join(Rails.root, "spec/web_mock/stripe_card_charge_fail.json")),
        status: 402
      )

      period_start = @subscription.current_period_start
      period_end   = @subscription.current_period_end

      SubscriptionUpdateWorker.perform_async(@subscription.id)
      @subscription.reload

      expect(@subscription.current_period_start).to be_within(100).of(period_start)
      expect(@subscription.current_period_end).to   be_within(100).of(period_end)
    end

    it "should set the subscription status to :past_due if the charge fails" do
      stub_request(:post, "https://api.stripe.com/v1/charges").to_return(
        body:   File.read(File.join(Rails.root, "spec/web_mock/stripe_card_charge_fail.json")),
        status: 402
      )

      SubscriptionUpdateWorker.perform_async(@subscription.id)
      @subscription.reload

      expect(@subscription.past_due?).to eq(true)
    end

    it "should set the subscription status to :unpaid if the charge fails 3 times" do
      stub_request(:post, "https://api.stripe.com/v1/charges").to_return(
        body:   File.read(File.join(Rails.root, "spec/web_mock/stripe_card_charge_fail.json")),
        status: 402
      )

      SubscriptionUpdateWorker.perform_async(@subscription.id)
      SubscriptionUpdateWorker.perform_async(@subscription.id)
      SubscriptionUpdateWorker.perform_async(@subscription.id)
      @subscription.reload

      expect(@subscription.unpaid?).to eq(true)
    end
  end

  context "Non-Renewing Subscription" do
    before(:each) do
      @subscription = create(:subscription, auto_renew: false, current_period_end: @end_time, payment_method: create(:stripe_card))
    end

    it "should end the subscription" do
      stub_request(:post, "https://api.stripe.com/v1/charges").to_return(
        body: File.read(File.join(Rails.root, "spec/web_mock/stripe_card_charge.json"))
      )

      SubscriptionUpdateWorker.perform_async(@subscription.id)
      @subscription.reload

      expect(@subscription.canceled?).to    eq(true)
      expect(@subscription.ended_at).to_not eq(nil)
    end
  end

end

require "rails_helper"

describe Subscriber, "#active_subscription?" do

  before(:each) do
    @organization = create(:organization)
    @plan = create(:subscription_plan)
  end

  it "should return false if the subscriber has never had a subscription" do
    expect(@organization.active_subscription?).to eq(false)
  end

  it "should return true after adding a new subscription" do
    @subscription = @organization.subscribe_to_plan(@plan)
    expect(@organization.active_subscription?).to eq(true)
  end

  it "should return false when the current subscription is not active" do
    @subscription = @organization.subscribe_to_plan(@plan)
    @subscription.status = :past_due
    @subscription.save

    expect(@organization.active_subscription?).to eq(false)
  end

  it "should return false after the current subscription ends" do
    @subscription = @organization.subscribe_to_plan(@plan)
    @subscription.ended_at = @organization.time.now - 1.day
    @subscription.save

    expect(@organization.active_subscription?).to eq(false)
  end
end

describe Subscriber, "#ad_hoc_invoice" do

  before(:each) do
    @organization = create(:organization)
  end

  it "should return an invoice that is due at the end of the next day" do
    end_of_next_day = (@organization.time.now + 1.day).end_of_day
    expect(@organization.ad_hoc_invoice.due_at).to be_within(100).of(end_of_next_day)
  end

  it "should return the same invoice if called multiple times before the next day" do
    expect(@organization.ad_hoc_invoice).to eq(@organization.ad_hoc_invoice)
  end

end

describe Subscriber, "#current_invoice" do

  before(:each) do
    @organization = create(:organization)
    @plan = create(:subscription_plan)
    @subscription = @organization.subscribe_to_plan(@plan)
  end

  it "should return the current invoice for subscriber's current subscription" do
    expect(@organization.current_invoice).to eq(@subscription.current_invoice)
  end

end

describe Subscriber, "#current_subscription" do

  before(:each) do
    @organization = create(:organization)
    @plan = create(:subscription_plan)
    @yearly_plan = create(:yearly_subscription_plan)
  end

  it "should return nil if the subscriber has never had a subscription" do
    expect(@organization.current_subscription).to eq(nil)
  end

  it "should return the first subscription that has not ended" do
    @subscription = @organization.subscribe_to_plan(@plan)
    expect(@organization.current_subscription).to eq(@subscription)

    @new_subscription = @organization.subscribe_to_plan(@yearly_plan)
    expect(@organization.current_subscription).to eq(@new_subscription)
  end

end

describe Subscriber, "#subscribe_to_plan(subscription_plan)" do

  before(:each) do
    @organization = create(:organization)
    @plan = create(:subscription_plan)
    @yearly_plan = create(:yearly_subscription_plan)
  end

  it "should return the created Subscription" do
    @subscription = @organization.subscribe_to_plan(@plan)
    expect(@subscription.class).to eq(Subscription)
  end

  it "should set the subscription plan on the Subscription" do
    @subscription = @organization.subscribe_to_plan(@plan)
    expect(@subscription.plan).to eq(@plan)
  end

  it "should set the trial end of the subscription based on the plan" do
    @subscription = @organization.subscribe_to_plan(@plan)

    trial_end = @organization.time.now + @plan.trial_length
    expect(@subscription.trial_ends_at).to be_within(100).of(trial_end)

    @yearly_plan.trial_period_days = 0
    @subscription = @organization.subscribe_to_plan(@yearly_plan)

    expect(@subscription.trial_ends_at).to be_within(100).of(@organization.time.now)
  end

  it "should set the current period start and end on the subscription" do
    @plan = create(:subscription_plan, trial_period_days: 0)
    @subscription = @organization.subscribe_to_plan(@plan)

    period_start = @organization.time.now
    period_end = period_start + @plan.interval_length

    expect(@subscription.current_period_start).to be_within(100).of(period_start)
    expect(@subscription.current_period_end).to   be_within(100).of(period_end)
  end

  it "should set the first period to be the length of the trial period" do
    @plan = create(:subscription_plan, trial_period_days: 10)
    @subscription = @organization.subscribe_to_plan(@plan)

    period_start = @organization.time.now
    period_end = period_start + 10.days

    expect(@subscription.current_period_start).to be_within(100).of(period_start)
    expect(@subscription.current_period_end).to   be_within(100).of(period_end)
  end

  context "subscriber has an existing subscription" do

    it "should end the current subscription if it exists" do
      @subscription = @organization.subscribe_to_plan(@plan)
      expect(@subscription.ended_at).to eq(nil)

      @new_subscription = @organization.subscribe_to_plan(@yearly_plan)
      @subscription.reload
      expect(@subscription.ended_at).to be_within(100).of(@organization.time.now)
    end

    it "should not end or create a new subscription if subscribing to the same plan" do
      @subscription = @organization.subscribe_to_plan(@plan)

      expect(@organization.subscriptions.count).to      eq(1)
      expect(@organization.subscribe_to_plan(@plan)).to eq(@subscription)
      expect(@organization.subscriptions.count).to      eq(1)
    end

    it "should give the subscriber prorated credit on their account from the old subscription" do
      @subscription = @organization.subscribe_to_plan(@plan)
      @subscription.active!

      # Let's make the current period 30 days long and we're right in the middle of it
      @subscription.current_period_start = @organization.time.now - 15.days
      @subscription.current_period_end = @organization.time.now + 15.days
      @subscription.save

      # And make the plan $30/interval so the price is $1/day
      @subscription.plan.price = Money.new(3000, "USD") # $30.00
      @subscription.plan.save

      # We should get half the money back as an account credit
      @new_subscription = @organization.subscribe_to_plan(@yearly_plan)

      expect(@organization.account_balance).to eq(Money.new(-1500, "USD")) # $15.00
    end

    it "should not give the subscriber a new trial period if they have an active plan" do
      @subscription = @organization.subscribe_to_plan(@plan)
      @subscription.trial_ends_at = @organization.time.now - 100.days
      @subscription.active!

      @new_subscription = @organization.subscribe_to_plan(@yearly_plan)
      expect(@new_subscription.active?).to eq(true)

      period_start = @organization.time.now
      period_end = period_start + @yearly_plan.interval_length

      expect(@new_subscription.current_period_start).to be_within(100).of(period_start)
      expect(@new_subscription.current_period_end).to   be_within(100).of(period_end)
    end

    it "should transfer the payment method to the new subscription" do
      stub_request(:post, "https://api.stripe.com/v1/customers").to_return(
        body: File.read(File.join(Rails.root, "spec/web_mock/stripe_customer.json"))
      )
      @stripe_card = create(:stripe_card)

      @subscription = @organization.subscribe_to_plan(@plan)
      @subscription.payment_method = @stripe_card
      @subscription.save

      # We should get half the money back as an account credit
      @new_subscription = @organization.subscribe_to_plan(@yearly_plan)
      expect(@new_subscription.payment_method).to eq(@stripe_card)
    end

  end

  context "subscriber has an existing trial subscription" do

    it "should set the trial end time of the new subscription to be the same as the old subscription if the same trial period" do
      @plan1 = create(:subscription_plan, name: "Plan 1", trial_period_days: 30)
      @plan2 = create(:subscription_plan, name: "Plan 2", trial_period_days: 30)

      @subscription1 = @organization.subscribe_to_plan(@plan1)
      @subscription2 = @organization.subscribe_to_plan(@plan2)

      expect(@subscription2.trial_ends_at).to be_within(100).of(@subscription1.trial_ends_at)
    end

    it "should extend the trial end time of the new subscription to match the new plan's trial period" do
      @plan1 = create(:subscription_plan, name: "Plan 1", trial_period_days: 15)
      @plan2 = create(:subscription_plan, name: "Plan 2", trial_period_days: 30)

      @subscription1 = @organization.subscribe_to_plan(@plan1)
      @subscription2 = @organization.subscribe_to_plan(@plan2)

      expect(@subscription2.trial_ends_at).to be_within(100).of(@subscription1.trial_ends_at + 15.days)
    end

  end

  context "subscriber has an existing free subscription" do

    it "should assign the new subscription's trial end based on date the subscriber was created" do
      @organization.created_at = Time.now - 10.days
      @organization.save
      @free_plan = create(:subscription_plan, price: 0, trial_period_days: 0)
      @paid_plan = create(:subscription_plan)

      @free_subscription = @organization.subscribe_to_plan(@free_plan)
      @paid_subscription = @organization.subscribe_to_plan(@paid_plan)

      expect(@paid_subscription.trial_ends_at).to be_within(100).of(@organization.created_at + @paid_plan.trial_length)
    end

  end

end

describe Subscriber, "#time" do

  it "should return a time object with the correct time zone" do
    @user = build(:user)
    expect(@user.time.name).to eq(@user.time_zone)
  end

end

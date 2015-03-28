require "rails_helper"

# ---------------------------------------------------------
# Instance Methods
# ---------------------------------------------------------

describe Subscription, "#current?" do

  before(:each) do
    @subscription = build(:subscription)
    @subscriber = @subscription.subscriber
  end

  context "subscription hasn't ended" do

    it "should return true during trial period" do
      @subscription.status = :trialing
      expect(@subscription.current?).to eq(true)
    end

    it "should return true if the subscription is active" do
      @subscription.status = :active
      expect(@subscription.current?).to eq(true)
    end

    it "should return true if the subscription is past due" do
      @subscription.status = :past_due
      expect(@subscription.current?).to eq(true)
    end

    it "should return true if the subscription is canceled" do
      @subscription.status = :canceled
      expect(@subscription.current?).to eq(true)
    end

    it "should return false if the subscription is unpaid" do
      @subscription.status = :unpaid
      expect(@subscription.current?).to eq(false)
    end

  end

  it "should return false if the subscription has ended" do
    @subscription.ended_at = Time.now - 10.days
    expect(@subscription.current?).to eq(false)
  end

end

describe Subscription, "#current_invoice" do

  before(:each) do
    @subscription = build(:subscription)
  end

  it "should build a new invoice if one hasn't been generated yet" do
    @invoice = @subscription.current_invoice
    expect(@invoice.due_at).to eq(@subscription.current_period_end)
  end

  it "should not generate a new invoice if it already exists for the period" do
    @invoice = @subscription.current_invoice
    expect(@subscription.current_invoice).to eq(@invoice)
  end

end

describe Subscription, "#current_period_credit" do

  before(:each) do
    @subscription = build(:subscription)
    @subscriber = @subscription.subscriber
  end

  it "should return nil during trial period" do
    @subscription.status = :trialing
    expect(@subscription.current_period_credit).to eq(nil)
  end

  it "should return nil if the plan is free" do
    @subscription.plan = SubscriptionPlan.new(price: 0)
    expect(@subscription.current_period_credit).to eq(nil)
  end

  it "should return nil if the current period is over" do
    @subscription.current_period_end = @subscriber.time.now - 1.day
    expect(@subscription.current_period_credit).to eq(nil)
  end

  it "should return a prorated credit amount for the rest of the billing period" do
    # Let's make the current period 20 days long and we're right in the middle of it
    @subscription.current_period_start = @subscriber.time.now - 10.days
    @subscription.current_period_end = @subscriber.time.now + 10.days

    # And make the plan $20/interval so the price is $1/day
    @subscription.plan.price = Money.new(2000, "USD") # $20.00

    # We should get half the money back as an account credit
    expect(@subscription.current_period_credit).to eq(Money.new(1000, "USD")) # $10.00
  end

end

describe Subscription, "#invoice_description" do
  before(:each) do
    @subscription = build(:subscription)
  end

  it "should include the subscription plan name" do
    expect(@subscription.invoice_description).to include(@subscription.plan.name)
  end

  it "should include the period start date" do
    expect(@subscription.invoice_description).to include(@subscription.next_period_start.strftime(Subscription::INVOICE_DATE_FORMAT))
  end

  it "should include the period end date" do
    expect(@subscription.invoice_description).to include(@subscription.next_period_end.strftime(Subscription::INVOICE_DATE_FORMAT))
  end
end

describe Subscription, "#next_period_end" do

  before(:each) do
    @subscription = build(:subscription)
  end

  it "should return the end date of the next period" do
    period_end = @subscription.subscriber.time.at(@subscription.current_period_end) + @subscription.plan.interval_length
    expect(@subscription.next_period_end).to be_within(100).of(period_end)
  end

  it "should return nil if the subscription won't auto-renew" do
    @subscription.auto_renew = false
    expect(@subscription.next_period_end).to eq(nil)
  end

  it "should return nil if the subscription has been canceled" do
    @subscription.status = :canceled
    expect(@subscription.next_period_end).to eq(nil)
  end

end

describe Subscription, "#next_period_start" do

  before(:each) do
    @subscription = build(:subscription)
  end

  it "should return the start date of the next period" do
    expect(@subscription.next_period_start).to eq(@subscription.subscriber.time.at(@subscription.current_period_end))
  end

  it "should return nil if the subscription won't auto-renew" do
    @subscription.auto_renew = false
    expect(@subscription.next_period_start).to eq(nil)
  end

  it "should return nil if the subscription has been canceled" do
    @subscription.status = :canceled
    expect(@subscription.next_period_start).to eq(nil)
  end

end

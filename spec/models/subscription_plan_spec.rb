require "rails_helper"

describe SubscriptionPlan, "#free?" do

  it "should return true if the plan is totally free" do
    @plan = build(:subscription_plan,
      price:          Money.new(0, "USD"),
      price_per_user: Money.new(0, "USD"),
      setup_price:    Money.new(0, "USD")
    )

    expect(@plan.free?).to eq(true)
  end

  it "should return false if the price > 0" do
    @plan = build(:subscription_plan,
      price:          Money.new(1000, "USD"), # $10.00
      price_per_user: Money.new(0, "USD"),
      setup_price:    Money.new(0, "USD")
    )

    expect(@plan.free?).to eq(false)
  end

  it "should return false if the price per user > 0" do
    @plan = build(:subscription_plan,
      price:          Money.new(0, "USD"),
      price_per_user: Money.new(1000, "USD"), # $10.00
      setup_price:    Money.new(0, "USD")
    )

    expect(@plan.free?).to eq(false)
  end

  it "should return false if the setup price > 0" do
    @plan = build(:subscription_plan,
      price:          Money.new(0, "USD"),
      price_per_user: Money.new(0, "USD"),
      setup_price:    Money.new(1000, "USD") # $10.00
    )

    expect(@plan.free?).to eq(false)
  end

end

describe SubscriptionPlan, "#interval_length" do

  it "should return the length of the subscription" do
    @plan = build(:subscription_plan)
    expect(@plan.interval_length).to eq(1.month)

    @plan.interval_count = 6
    expect(@plan.interval_length).to eq(6.months)

    @plan.interval_count = 1
    @plan.interval = :year
    expect(@plan.interval_length).to eq(1.year)
  end

end

describe SubscriptionPlan, "#trial_length" do

  it "should return the length of the trial" do
    @plan = build(:subscription_plan)
    expect(@plan.trial_length).to eq(14.days)

    @plan = build(:yearly_subscription_plan)
    expect(@plan.trial_length).to eq(30.days)
  end

end

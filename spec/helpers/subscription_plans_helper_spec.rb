require "rails_helper"

describe SubscriptionPlansHelper, "#upgrade_message(current_subscription, new_plan)" do

  context "There is no current subscription" do

    before(:each) do
      @subscription = nil
      @plan = create(:subscription_plan)
    end

    it "should include the trial period length" do
      expect(upgrade_message(@subscription, @plan)).to include("#{@plan.trial_period_days.to_s}")
    end

    it "should include the trial end date" do
      trial_ends_at = Time.now + @plan.trial_length
      expect(upgrade_message(@subscription, @plan)).to include(trial_ends_at.strftime("%h #{trial_ends_at.day.ordinalize}, %Y"))
    end

  end

  context "There is an existing trial subscription" do

    before(:each) do
      @subscription = create(:subscription, trial_ends_at: Time.now + 10.days, status: :trialing)
      @plan = create(:subscription_plan, trial_period_days: 30)
    end

    it "should include the information about the trial continuing if there is one" do
      expect(upgrade_message(@subscription, @plan)).to include("Your free trial will continue")
    end

    it "should include the trial end date if there is a trial" do
      trial_length_diff = @plan.trial_length - @subscription.plan.trial_length
      trial_ends_at = @subscription.trial_ends_at + trial_length_diff

      expect(upgrade_message(@subscription, @plan)).to include(trial_ends_at.strftime("%h #{trial_ends_at.day.ordinalize}, %Y"))
    end

  end

  context "There is an existing active, paid subscription" do

    before(:each) do
      @subscription = create(:subscription, current_period_start: Time.now - 20.days, current_period_end: Time.now + 10.days)
      @plan = create(:subscription_plan)
    end

    it "should include the account credit information from canceling the existing plan" do
      expect(upgrade_message(@subscription, @plan)).to include(number_to_currency(@subscription.current_period_credit))
    end

    it "should include the new charge and billing period" do
      upgrade_message = upgrade_message(@subscription, @plan)

      new_charge = number_to_currency(@plan.price)
      expect(upgrade_message).to include(new_charge)

      new_period_start = Time.now
      new_period_end   = new_period_start + @plan.interval_count.send(@plan.interval)

      expect(upgrade_message).to include(new_period_start.strftime("%h #{new_period_start.day.ordinalize}, %Y"))
      expect(upgrade_message).to include(new_period_end.strftime("%h #{new_period_end.day.ordinalize}, %Y"))
    end

  end

  context "There is an existing active, free subscription" do

    before(:each) do
      @subscription = create(:subscription, current_period_start: Time.now - 10.days, current_period_end: Time.now + 20.days)
      @subscription.plan.price = 0
      @subscription.plan.save
      @subscription.subscriber.created_at = Time.now - 10.days
      @subscription.subscriber.save
      @plan = create(:subscription_plan)
    end

    it "should include the trial period length if the account is new enough" do
      expect(upgrade_message(@subscription, @plan)).to include("#{@plan.trial_period_days.to_s} Day Free Trial")
    end

    it "should include the trial period end date if the account is new enough" do
      trial_ends_at = @subscription.subscriber.created_at + @plan.trial_length
      expect(upgrade_message(@subscription, @plan)).to include(trial_ends_at.strftime("%h #{trial_ends_at.day.ordinalize}, %Y"))
    end

    it "should include the new charge and billing period if the account is older than the new trial period" do
      @subscription.subscriber.created_at = Time.now - 100.days
      @subscription.subscriber.save

      upgrade_message = upgrade_message(@subscription, @plan)

      new_charge = number_to_currency(@plan.price)
      expect(upgrade_message).to include(new_charge)

      new_period_start = Time.now
      new_period_end   = new_period_start + @plan.interval_count.send(@plan.interval)

      expect(upgrade_message).to include(new_period_start.strftime("%h #{new_period_start.day.ordinalize}, %Y"))
      expect(upgrade_message).to include(new_period_end.strftime("%h #{new_period_end.day.ordinalize}, %Y"))
    end

  end

  context "The new plan is free" do

    before(:each) do
      @subscription = nil
      @plan = create(:subscription_plan, price: 0, trial_period_days: 0)
    end

    it "should include information about the new plan being free" do
      expect(upgrade_message(@subscription, @plan)).to include("FREE")
    end

    it "should include a message for never being charged" do
      expect(upgrade_message(@subscription, @plan)).to include("You will not be charged")
    end

  end

end

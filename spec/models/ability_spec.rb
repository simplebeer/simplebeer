require "rails_helper"

describe Ability, "User with Single User subscription" do

  context "should be able to" do

    before(:each) do
      @user = create(:user)
      @ability = Ability.new(@user)
      @expected_result = true # Fewer copy/paste errors ftw!

      stub_request(:post, "https://api.stripe.com/v1/customers").to_return(
        body: File.read(File.join(Rails.root, "spec/web_mock/stripe_customer.json"))
      )
    end

    it "update their own account" do
      expect(@ability.can?(:update, @user)).to eq(@expected_result)
    end

    it "delete their own account" do
      expect(@ability.can?(:destroy, @user)).to eq(@expected_result)
    end

    it "update their subscription" do
      @subscription = @user.current_subscription
      expect(@ability.can?(:update, @subscription)).to eq(@expected_result)
    end

    it "create a new payment method" do
      expect(@ability.can?(:create, build(:stripe_card, subscriber: @user))).to eq(@expected_result)
    end

    it "delete a payment method they created" do
      @stripe_card = create(:stripe_card, subscriber: @user)
      @ability = Ability.new(@user)
      expect(@ability.can?(:destroy, @stripe_card)).to eq(@expected_result)
    end

    it "create a new subscription" do
      expect(@ability.can?(:create, build(:subscription, subscriber: @user))).to eq(@expected_result)
    end

    it "create a new organization" do
      expect(@ability.can?(:create, Organization)).to eq(@expected_result)
    end

  end

  context "should NOT be able to" do

    before(:each) do
      @user = create(:user)
      @another_user = create(:user)
      @ability = Ability.new(@user)
      @expected_result = false # Fewer copy/paste errors ftw!

      stub_request(:post, "https://api.stripe.com/v1/customers").to_return(
        body: File.read(File.join(Rails.root, "spec/web_mock/stripe_customer.json"))
      )
    end

    it "update another user's account" do
      expect(@ability.can?(:update, @another_user)).to eq(@expected_result)
    end

    it "delete another user's account" do
      expect(@ability.can?(:destroy, @another_user)).to eq(@expected_result)
    end

    it "update another user's subscription" do
      @subscription = @another_user.current_subscription
      expect(@ability.can?(:update, @subscription)).to eq(@expected_result)
    end

    it "update another user's subscription's payment method" do
      @payment_method = @another_user.current_subscription.payment_method
      @payment_method = create(:stripe_card)
      @payment_method.save

      expect(@ability.can?(:update, @payment_method)).to eq(@expected_result)
    end

    it "create a new payment method for another user" do
      expect(@ability.can?(:create, build(:stripe_card, subscriber: @another_user))).to eq(@expected_result)
    end

    it "delete another user's payment method" do
      @stripe_card = create(:stripe_card, subscriber: @another_user)
      expect(@ability.can?(:destroy, @stripe_card)).to eq(@expected_result)
    end

    it "delete the payment method on their current subscription" do
      @payment_method = @user.current_subscription.payment_method
      @payment_method = create(:stripe_card)
      @payment_method.save

      expect(@ability.can?(:destroy, @payment_method)).to eq(@expected_result)
    end

    it "create a new subscription for another user" do
      expect(@ability.can?(:create, build(:subscription, subscriber: @another_user))).to eq(@expected_result)
    end

  end

end

describe Ability, "Organization Owner" do

  context "should be able to" do

    before(:each) do
      @user = create(:user, subscription_plan_id: create(:organization_subscription_plan).id)
      @organization = @user.organizations.first
      @organization.subscriptions << create(:subscription)
      @ability = Ability.new(@user)
      @expected_result = true # Fewer copy/paste errors ftw!

      stub_request(:post, "https://api.stripe.com/v1/customers").to_return(
        body: File.read(File.join(Rails.root, "spec/web_mock/stripe_customer.json"))
      )
    end

    it "update their own account" do
      expect(@ability.can?(:update, @user)).to eq(@expected_result)
    end

    it "delete their own account" do
      expect(@ability.can?(:destroy, @user)).to eq(@expected_result)
    end

    it "update the organization" do
      expect(@ability.can?(:update, @organization)).to eq(@expected_result)
    end

    it "delete the organization" do
      expect(@ability.can?(:destroy, @organization)).to eq(@expected_result)
    end

    it "update the organization's subscription" do
      @subscription = @organization.current_subscription
      expect(@ability.can?(:update, @subscription)).to eq(@expected_result)
    end

    it "create a new payment method for the organization" do
      expect(@ability.can?(:create, build(:stripe_card, subscriber: @organization))).to eq(@expected_result)
    end

    it "delete a payment method created for the organization" do
      @stripe_card = create(:stripe_card, subscriber: @organization)
      @ability = Ability.new(@user)
      expect(@ability.can?(:destroy, @stripe_card)).to eq(@expected_result)
    end

    it "create a new subscription for the organization" do
      expect(@ability.can?(:create, build(:subscription, subscriber: @organization))).to eq(@expected_result)
    end

    it "create a new organization memberships for the organization" do
      expect(@ability.can?(:create, build(:organization_membership, organization: @organization))).to eq(@expected_result)
    end

    it "delete organization memberships from the organization" do
      @organization_membership = create(:organization_membership, organization: @organization)
      expect(@ability.can?(:destroy, @organization_membership)).to eq(@expected_result)
    end

  end

  context "should NOT be able to" do

    before(:each) do
      @user = create(:user, subscription_plan_id: create(:organization_subscription_plan).id)
      @organization = create(:organization)
      @organization.subscriptions << create(:subscription)
      @ability = Ability.new(@user)
      @expected_result = false # Fewer copy/paste errors ftw!

      stub_request(:post, "https://api.stripe.com/v1/customers").to_return(
        body: File.read(File.join(Rails.root, "spec/web_mock/stripe_customer.json"))
      )
    end

    it "update another user's account" do
      @another_user = create(:user)
      expect(@ability.can?(:update, @another_user)).to eq(@expected_result)
    end

    it "delete another user's account" do
      @another_user = create(:user)
      expect(@ability.can?(:destroy, @another_user)).to eq(@expected_result)
    end

    it "update another organization" do
      expect(@ability.can?(:update, @organization)).to eq(@expected_result)
    end

    it "delete another organization" do
      expect(@ability.can?(:destroy, @organization)).to eq(@expected_result)
    end

    it "update another organization's subscription" do
      @subscription = @organization.current_subscription
      expect(@ability.can?(:update, @subscription)).to eq(@expected_result)
    end

    it "update another organization's subscription's payment method" do
      @payment_method = @organization.current_subscription.payment_method
      @payment_method = create(:stripe_card)
      @payment_method.save

      expect(@ability.can?(:update, @payment_method)).to eq(@expected_result)
    end

    it "create a new payment method for another organization" do
      expect(@ability.can?(:create, build(:stripe_card, subscriber: @organization))).to eq(@expected_result)
    end

    it "delete another organization's payment method" do
      @stripe_card = create(:stripe_card, subscriber: @organization)
      expect(@ability.can?(:destroy, @stripe_card)).to eq(@expected_result)
    end

    it "create a new subscription for another organization" do
      expect(@ability.can?(:create, build(:subscription, subscriber: @organization))).to eq(@expected_result)
    end

    it "create a new organization memberships for another organization" do
      expect(@ability.can?(:create, build(:organization_membership, organization: @organization))).to eq(@expected_result)
    end

    it "delete organization memberships from another organization" do
      @organization_membership = create(:organization_membership, organization: @organization)
      expect(@ability.can?(:destroy, @organization_membership)).to eq(@expected_result)
    end

  end

end

describe Ability, "Organization Admin" do
  context "should be able to" do

    before(:each) do
      @user = create(:user, subscription_plan_id: create(:organization_subscription_plan).id)
      @organization = @user.organizations.first
      @organization.subscriptions << create(:subscription)
      @organization_membership = @user.organization_memberships.first
      @organization_membership.update_attribute(:role, :admin)
      @ability = Ability.new(@user)
      @expected_result = true # Fewer copy/paste errors ftw!

      stub_request(:post, "https://api.stripe.com/v1/customers").to_return(
        body: File.read(File.join(Rails.root, "spec/web_mock/stripe_customer.json"))
      )
    end

    it "update their own account" do
      expect(@ability.can?(:update, @user)).to eq(@expected_result)
    end

    it "delete their own account" do
      expect(@ability.can?(:destroy, @user)).to eq(@expected_result)
    end

    it "update the organization" do
      expect(@ability.can?(:update, @organization)).to eq(@expected_result)
    end

    it "update the organization's subscription" do
      @subscription = @organization.current_subscription
      expect(@ability.can?(:update, @subscription)).to eq(@expected_result)
    end

    it "create a new payment method for the organization" do
      expect(@ability.can?(:create, build(:stripe_card, subscriber: @organization))).to eq(@expected_result)
    end

    it "delete a payment method created for the organization" do
      @stripe_card = create(:stripe_card, subscriber: @organization)
      @ability = Ability.new(@user)
      expect(@ability.can?(:destroy, @stripe_card)).to eq(@expected_result)
    end

    it "create a new subscription for the organization" do
      expect(@ability.can?(:create, build(:subscription, subscriber: @organization))).to eq(@expected_result)
    end

    it "create a new organization memberships for the organization" do
      expect(@ability.can?(:create, build(:organization_membership, organization: @organization))).to eq(@expected_result)
    end

    it "delete organization memberships from the organization" do
      @organization_membership = create(:organization_membership, organization: @organization)
      expect(@ability.can?(:destroy, @organization_membership)).to eq(@expected_result)
    end

    it "update organization memberships from the organization" do
      @organization_membership = create(:organization_membership, organization: @organization)
      expect(@ability.can?(:update, @organization_membership)).to eq(@expected_result)
    end

  end

  context "should NOT be able to" do

    before(:each) do
      @user = create(:user, subscription_plan_id: create(:organization_subscription_plan).id)
      @organization_membership = @user.organization_memberships.first
      @organization_membership.update_attribute(:role, :admin)
      @organization = create(:organization)
      @organization.subscriptions << create(:subscription)
      @ability = Ability.new(@user)
      @expected_result = false # Fewer copy/paste errors ftw!

      stub_request(:post, "https://api.stripe.com/v1/customers").to_return(
        body: File.read(File.join(Rails.root, "spec/web_mock/stripe_customer.json"))
      )
    end

    it "update another user's account" do
      @another_user = create(:user)
      expect(@ability.can?(:update, @another_user)).to eq(@expected_result)
    end

    it "delete another user's account" do
      @another_user = create(:user)
      expect(@ability.can?(:destroy, @another_user)).to eq(@expected_result)
    end

    it "delete the organization" do
      @organization = @user.organizations.first
      expect(@ability.can?(:destroy, @organization)).to eq(@expected_result)
    end

    it "update another organization" do
      expect(@ability.can?(:update, @organization)).to eq(@expected_result)
    end

    it "delete another organization" do
      expect(@ability.can?(:destroy, @organization)).to eq(@expected_result)
    end

    it "update another organization's subscription" do
      @subscription = @organization.current_subscription
      expect(@ability.can?(:update, @subscription)).to eq(@expected_result)
    end

    it "update another organization's subscription's payment method" do
      @payment_method = @organization.current_subscription.payment_method
      @payment_method = create(:stripe_card)
      @payment_method.save

      expect(@ability.can?(:update, @payment_method)).to eq(@expected_result)
    end

    it "create a new payment method for another organization" do
      expect(@ability.can?(:create, build(:stripe_card, subscriber: @organization))).to eq(@expected_result)
    end

    it "delete another organization's payment method" do
      @stripe_card = create(:stripe_card, subscriber: @organization)
      expect(@ability.can?(:destroy, @stripe_card)).to eq(@expected_result)
    end

    it "create a new subscription for another organization" do
      expect(@ability.can?(:create, build(:subscription, subscriber: @organization))).to eq(@expected_result)
    end

    it "create a new organization memberships for another organization" do
      expect(@ability.can?(:create, build(:organization_membership, organization: @organization))).to eq(@expected_result)
    end

    it "delete organization memberships from another organization" do
      @organization_membership = create(:organization_membership, organization: @organization)
      expect(@ability.can?(:destroy, @organization_membership)).to eq(@expected_result)
    end

    it "update organization memberships from another organization" do
      @organization_membership = create(:organization_membership, organization: @organization)
      expect(@ability.can?(:update, @organization_membership)).to eq(@expected_result)
    end

  end
end

describe Ability, "Organization Member" do
  context "should be able to" do

    before(:each) do
      @user = create(:user, subscription_plan_id: create(:organization_subscription_plan).id)
      @organization = @user.organizations.first
      @organization.subscriptions << create(:subscription)
      @organization_membership = @user.organization_memberships.first
      @organization_membership.update_attribute(:role, :member)
      @ability = Ability.new(@user)
      @expected_result = true # Fewer copy/paste errors ftw!

      stub_request(:post, "https://api.stripe.com/v1/customers").to_return(
        body: File.read(File.join(Rails.root, "spec/web_mock/stripe_customer.json"))
      )
    end

    it "update their own account" do
      expect(@ability.can?(:update, @user)).to eq(@expected_result)
    end

    it "delete their own account" do
      expect(@ability.can?(:destroy, @user)).to eq(@expected_result)
    end

  end

  context "should NOT be able to" do

    before(:each) do
      @user = create(:user, subscription_plan_id: create(:organization_subscription_plan).id)
      @organization = @user.organizations.first
      @organization.subscriptions << create(:subscription)
      @organization_membership = @user.organization_memberships.first
      @organization_membership.update_attribute(:role, :member)
      @another_organization = create(:organization)
      @another_organization.subscriptions << create(:subscription)
      @ability = Ability.new(@user)
      @expected_result = false # Fewer copy/paste errors ftw!

      stub_request(:post, "https://api.stripe.com/v1/customers").to_return(
        body: File.read(File.join(Rails.root, "spec/web_mock/stripe_customer.json"))
      )
    end

    it "update the organization" do
      expect(@ability.can?(:update, @organization)).to eq(@expected_result)
    end

    it "update the organization's subscription" do
      @subscription = @organization.current_subscription
      expect(@ability.can?(:update, @subscription)).to eq(@expected_result)
    end

    it "update the organization subscription's payment method" do
      @payment_method = @organization.current_subscription.payment_method
      @payment_method = create(:stripe_card)
      @payment_method.save

      expect(@ability.can?(:update, @payment_method)).to eq(@expected_result)
    end

    it "create a new payment method for the organization" do
      expect(@ability.can?(:create, build(:stripe_card, subscriber: @organization))).to eq(@expected_result)
    end

    it "delete a payment method created for the organization" do
      @stripe_card = create(:stripe_card, subscriber: @organization)
      @ability = Ability.new(@user)
      expect(@ability.can?(:destroy, @stripe_card)).to eq(@expected_result)
    end

    it "create a new subscription for the organization" do
      expect(@ability.can?(:create, build(:subscription, subscriber: @organization))).to eq(@expected_result)
    end

    it "create a new organization memberships for the organization" do
      expect(@ability.can?(:create, build(:organization_membership, organization: @organization))).to eq(@expected_result)
    end

    it "delete organization memberships from the organization" do
      @organization_membership = create(:organization_membership, organization: @organization)
      expect(@ability.can?(:destroy, @organization_membership)).to eq(@expected_result)
    end

    it "update organization memberships from the organization" do
      @organization_membership = create(:organization_membership, organization: @organization)
      expect(@ability.can?(:update, @organization_membership)).to eq(@expected_result)
    end

    it "update another user's account" do
      @another_user = create(:user)
      expect(@ability.can?(:update, @another_user)).to eq(@expected_result)
    end

    it "delete another user's account" do
      @another_user = create(:user)
      expect(@ability.can?(:destroy, @another_user)).to eq(@expected_result)
    end

    it "update another organization" do
      expect(@ability.can?(:update, @another_organization)).to eq(@expected_result)
    end

    it "delete another organization" do
      expect(@ability.can?(:destroy, @another_organization)).to eq(@expected_result)
    end

    it "update another organization's subscription" do
      @subscription = @another_organization.current_subscription
      expect(@ability.can?(:update, @subscription)).to eq(@expected_result)
    end

    it "update another organization's subscription's payment method" do
      @payment_method = @another_organization.current_subscription.payment_method
      @payment_method = create(:stripe_card)
      @payment_method.save

      expect(@ability.can?(:update, @payment_method)).to eq(@expected_result)
    end

    it "create a new payment method for another organization" do
      expect(@ability.can?(:create, build(:stripe_card, subscriber: @another_organization))).to eq(@expected_result)
    end

    it "delete another organization's payment method" do
      @stripe_card = create(:stripe_card, subscriber: @another_organization)
      expect(@ability.can?(:destroy, @stripe_card)).to eq(@expected_result)
    end

    it "create a new subscription for another organization" do
      expect(@ability.can?(:create, build(:subscription, subscriber: @another_organization))).to eq(@expected_result)
    end

    it "create a new organization memberships for another organization" do
      expect(@ability.can?(:create, build(:organization_membership, organization_id: @another_organization.id))).to eq(@expected_result)
    end

    it "delete organization memberships from another organization" do
      @organization_membership = create(:organization_membership, organization: @another_organization)
      expect(@ability.can?(:destroy, @organization_membership)).to eq(@expected_result)
    end

    it "update organization memberships from another organization" do
      @organization_membership = create(:organization_membership, organization: @another_organization)
      expect(@ability.can?(:update, @organization_membership)).to eq(@expected_result)
    end

  end
end

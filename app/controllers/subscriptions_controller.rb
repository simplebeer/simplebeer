class SubscriptionsController < ApplicationController
  layout "account"

  def create
    @subscription_plan = SubscriptionPlan.find(subscription_params[:subscription_plan_id])
    authorize! :create, Subscription.new(subscriber: @subscriber)

    @subscriber.subscribe_to_plan(@subscription_plan)
    redirect_to edit_subscriber_subscription_path, notice: "Subscription updated successfully."
  end

  def edit
    @subscription = @subscriber.current_subscription
    authorize! :update, @subscription

    @invoices = ["abc123", "xyz987", "xkcd345"]
    # @invoices = @subscriber.invoices

    @title = "Billing ~ #{@subscriber.display_name}"
  end

  def new
    @current_subscription = @subscriber.current_subscription
    @subscription = Subscription.new(
      subscriber: @subscriber,
      plan:       @current_subscription ? @current_subscription.plan : nil
    )
    authorize! :create, @subscription

    @subscription_plans = SubscriptionPlan.active
    @subscription_plans = params[:resource_name] == "users" ? @subscription_plans.user : @subscription_plans.organization

    @title = "Billing ~ Change Plan ~ #{@subscriber.display_name}"
  end

  def update
    @subscription = @subscriber.current_subscription
    authorize! :update, @subscription

    if @subscription.update_attributes(subscription_params)
      redirect_to edit_subscriber_subscription_path, notice: "Payment method updated successfully."
    else
      redirect_to edit_subscriber_subscription_path, alert: "There was a problem updating the payment method."
    end
  end

private

  def subscription_params
    params.require(:subscription).permit(
      :subscription_plan_id,
      :payment_method_id,
      :payment_method_type
    )
  end

end

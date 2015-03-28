class PaymentMethodsController < ApplicationController
  layout "account"
  before_action :set_subscription

  def create
    @stripe_card = StripeCard.new(stripe_card_params)
    @stripe_card.subscriber = @subscriber
    authorize! :create, @stripe_card

    if @stripe_card.save
      @subscription.reload
      if @subscription.payment_method == @stripe_card
        redirect_to edit_subscriber_subscription_path, notice: "Payment method added successfully."
      else
        redirect_to edit_subscriber_subscription_payment_method_path, notice: "Payment method created successfully."
      end
    else
      redirect_to edit_subscriber_subscription_payment_method_path, alert: "There was a problem saving the payment method."
    end
  end

  def destroy
    @stripe_card = StripeCard.find(params[:id])
    authorize! :destroy, @stripe_card

    if @stripe_card.destroy
      redirect_to edit_subscriber_subscription_payment_method_path, notice: "Payment method deleted successfully."
    else
      redirect_to edit_subscriber_subscription_payment_method_path, alert: "Payment method cannot be deleted if assigned to a subscription."
    end
  end

  def edit
    @stripe_card = StripeCard.new
    @stripe_card.subscriber = @subscriber
    authorize! :update, @stripe_card

    @stripe_cards = @subscriber.stripe_cards

    @title = "Billing ~ Payment Method ~ #{@subscriber.display_name}"
  end

private

  def set_subscription
    @subscription = @subscriber.current_subscription
  end

  def stripe_card_params
    params.require(:stripe_card).permit(
      :brand,
      :exp_month,
      :exp_year,
      :last4,
      :stripe_card_id,
      :stripe_token,
    )
  end

end

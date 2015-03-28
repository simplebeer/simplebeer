class SubscriptionUpdateWorker
  include Sidekiq::Worker

  def perform(subscription_id)
    @subscription = Subscription.find_by_id(subscription_id)
    return unless @subscription

    @invoice = @subscription.current_invoice

    if @invoice.finalized?
      retry_invoice_charge
    elsif (@subscription.trialing? || @subscription.auto_renew) && !@subscription.canceled?
      renew_subscription
    else
      end_subscription
    end
  end

private

  def end_subscription
    if @invoice.finalize!
      @subscription.end!
    else
      @subscription.past_due!
    end
  end

  def renew_subscription
    @invoice.line_items.create(
      amount:      @subscription.plan.price,
      description: @subscription.invoice_description
    )

    if @invoice.finalize!
      @subscription.activate!
    else
      @subscription.past_due!
    end
  end

  def retry_invoice_charge
    if @invoice.finalize!
      if @subscription.auto_renew && !@subscription.canceled?
        @subscription.activate!
      else
        @subscription.end!
      end
    elsif @invoice.charges.count < 3
      @subscription.past_due!
    else
      @subscription.unpaid!
    end
  end

end

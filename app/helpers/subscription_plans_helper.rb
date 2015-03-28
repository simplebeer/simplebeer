module SubscriptionPlansHelper

  # Returns account credit and new billing information about upgrading to a new plan.
  # @param current_subscription [Subscription]
  # @param new_plan [SubscriptionPlan]
  # @return [String]
  def upgrade_message(current_subscription, new_plan)
    return free_subscription_message(current_subscription, new_plan) if (current_subscription.nil? || current_subscription.trialing?) && new_plan.free?
    return first_subscription_message(new_plan)                      if current_subscription.nil?
    return update_trial_message(current_subscription, new_plan)      if current_subscription.trialing?
    return new_paid_plan_message(current_subscription, new_plan)     if current_subscription.active? && current_subscription.plan.free?
    return downgrade_to_free_message(current_subscription, new_plan) if current_subscription.active? && new_plan.free?

    update_plan_message(current_subscription, new_plan)
  end

private

  # The message for downgrading from an active paid plan to a free plan.
  # @return [String]
  def downgrade_to_free_message(current_subscription, new_plan)
    message = "You will receive a <strong>#{number_to_currency(current_subscription.current_period_credit)}</strong> credit on your account.<br>"
    message += "You will not be charged for the life of the selected plan."
    message.html_safe
  end

  # The message for signing up for a new free plan with no existing plan.
  # @return [String]
  def free_subscription_message(current_subscription, new_plan)
    message  = "<strong>You have selected a FREE plan.</strong><br>"
    message += "You will not be charged for the life of the selected plan."
    message.html_safe
  end

  # The message for signing up for a new paid plan with a trial period.
  # @return [String]
  def first_subscription_message(new_plan)
    message = "<strong>#{new_plan.trial_period_days.to_s} Day Free Trial</strong><br>"

    trial_ends_at = Time.now + new_plan.trial_length
    message += "The free trial will end on #{trial_ends_at.strftime("%h #{trial_ends_at.day.ordinalize}, %Y")}."

    message.html_safe
  end

  # The message for signing up for a new paid plan from an existing free plan.
  # @return [String]
  def new_paid_plan_message(current_subscription, new_plan)
    message = ""
    trial_ends_at = current_subscription.subscriber.created_at + new_plan.trial_length

    if trial_ends_at > Time.now
      message += "<strong>#{new_plan.trial_period_days.to_s} Day Free Trial</strong><br>"
      message += "The free trial will end on #{trial_ends_at.strftime("%h #{trial_ends_at.day.ordinalize}, %Y")}."
    else
      new_period_start = Time.now
      new_period_end   = new_period_start + new_plan.interval_count.send(new_plan.interval)
      message += "&nbsp;<br>You will be charged <strong>#{number_to_currency(new_plan.price)}</strong> for #{new_period_start.strftime("%h #{new_period_start.day.ordinalize}, %Y")} &#8211; #{new_period_end.strftime("%h #{new_period_end.day.ordinalize}, %Y")}."
    end

    message.html_safe
  end

  # The message for signing up for a paid plan with a trial while still in a trial period.
  # @return [String]
  def update_trial_message(current_subscription, new_plan)
    message = "Your free trial will continue.<br>"

    trial_length_diff = new_plan.trial_length - current_subscription.plan.trial_length
    trial_ends_at = current_subscription.trial_ends_at + trial_length_diff
    message += "The free trial will end on #{trial_ends_at.strftime("%h #{trial_ends_at.day.ordinalize}, %Y")}."

    message.html_safe
  end

  # The message for moving from one active paid plan to another.
  # @return [String]
  def update_plan_message(current_subscription, new_plan)
    message = "You will receive a <strong>#{number_to_currency(current_subscription.current_period_credit)}</strong> credit on your account.<br>"

    new_period_start = Time.now
    new_period_end   = new_period_start + new_plan.interval_count.send(new_plan.interval)
    message += "You will be charged <strong>#{number_to_currency(new_plan.price)}</strong> for #{new_period_start.strftime("%h #{new_period_start.day.ordinalize}, %Y")} &#8211; #{new_period_end.strftime("%h #{new_period_end.day.ordinalize}, %Y")}."

    message.html_safe
  end

end

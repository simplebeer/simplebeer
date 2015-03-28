class SubscriptionPlan < ActiveRecord::Base
  scope :active, -> { where(active: true) }

  monetize :price_cents
  monetize :price_per_user_cents
  monetize :setup_price_cents

  validates :interval, :interval_count, presence: true

  scope :active, -> { where(active: true) }

  enum account_type: {
    user:         0,
    organization: 1
  }

  enum interval: {
    month: 0,
    year:  1
  }

  # Convenience method for determining if the plan is completely free.
  # @return [Boolean]
  def free?
    self.price == 0 && self.price_per_user == 0 && self.setup_price == 0
  end

  # Returns the the length of time for the plan's
  # interval used for calculating the subscription's
  # billing cycles and ending dates.
  #
  # Example:
  #
  #   end_date = start_date + plan.interval_length
  #
  # @return [Fixnum, Float]
  def interval_length
    self.interval_count.send(self.interval)
  end

  # Returns the the length of time for the plan's trial period.
  #
  # Example:
  #
  #   trial_end = start_date + plan.trial_length
  #
  # @return [Fixnum, Float]
  def trial_length
    self.trial_period_days.to_i.days
  end
end

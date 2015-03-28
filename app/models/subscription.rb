# Ties an organization to a SubscriptionPlan and contains the information about the
# current billing cycle, trial end time, whether it auto renews, etc.
class Subscription < ActiveRecord::Base
  acts_as_paranoid

  # Relationships
  belongs_to :payment_method, polymorphic: true
  belongs_to :plan, class_name: "SubscriptionPlan", foreign_key: "subscription_plan_id"
  belongs_to :subscriber, polymorphic: true

  # Validations
  validates :plan,       presence: true
  validates :subscriber, presence: true

  # Callbacks
  before_save :build_from_plan

  # Scopes
  scope :current, -> { where("ended_at IS NULL OR ended_at > ?", Time.now) }
  scope :ended,   -> { where("ended_at IS NOT NULL AND ended_at <= ?", Time.now) }

  # Constants
  INVOICE_DATE_FORMAT = "%F"

  enum status: {
    trialing: 0,
    active:   1,
    past_due: 2,
    unpaid:   3,
    canceled: 4
  }

  # Updates the current period start and end,
  # and updates the status to :active.
  def activate!
    period_start = self.next_period_start
    period_end   = self.next_period_end

    self.current_period_start = period_start
    self.current_period_end   = period_end
    self.active!
  end

  # Returns whether or not the subscription is still in use.
  # @return [Boolean]
  def current?
    in_use = !self.unpaid?
    not_ended = self.ended_at.nil? || self.ended_at > Time.now

    in_use && not_ended
  end

  # The invoice for the current period.
  # @return [Invoice]
  def current_invoice
    invoice = self.subscriber.invoices.where(due_at: self.current_period_end, subscription: self).first_or_create

    if invoice.payment_method != self.payment_method
      invoice.payment_method = self.payment_method
      invoice.save
    end

    invoice
  end

  # The amount the subscriber should be credited if
  # they cancel the subscription right now. Nil is
  # returned if there is no credit given.
  # @return [Money]
  def current_period_credit
    return if self.trialing?
    return if self.plan.price == 0
    return if self.current_period_end < self.subscriber.time.now

    period_start = self.subscriber.time.at(self.current_period_start)
    period_end   = self.subscriber.time.at(self.current_period_end)

    current_period_days = (period_end - period_start) / 1.day
    current_period_days_left = ((period_end - self.subscriber.time.now) / 1.day).round
    price_per_day = self.plan.price / current_period_days

    price_per_day * current_period_days_left
  end

  # Ends the subscription and sets the status to :canceled.
  def end!
    self.ended_at = self.subscriber.time.now
    self.canceled!
  end

  # The description for the subscription's next period.
  # @return [String]
  def invoice_description
    "#{self.plan.name} Plan: #{self.next_period_start.strftime(INVOICE_DATE_FORMAT)} - #{self.next_period_end.strftime(INVOICE_DATE_FORMAT)}"
  end

  # For renewing subscriptions, the end date of the next billing period is returned.
  # Nil is returned for non-renewing and canceled subscriptions
  # @return [DateTime]
  def next_period_end
    return unless (self.trialing? || self.auto_renew) && !self.canceled?
    self.next_period_start + self.plan.interval_length
  end

  # For renewing subscriptions, the start date of the next billing period is returned.
  # Nil is returned for non-renewing and canceled subscriptions
  # @return [DateTime]
  def next_period_start
    return unless (self.trialing? || self.auto_renew) && !self.canceled?
    self.subscriber.time.at(self.current_period_end)
  end

private

  def build_from_plan
    return unless self.plan

    self.trial_ends_at        ||= self.subscriber.time.now + self.plan.trial_length
    self.current_period_start ||= self.subscriber.time.now
    self.current_period_end   ||= self.subscriber.time.at(self.current_period_start) + self.plan.interval_length
  end

end

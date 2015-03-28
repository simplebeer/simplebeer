class Invoice < ActiveRecord::Base
  acts_as_paranoid

  # Relationships
  belongs_to :payment_method, -> { with_deleted }, polymorphic: true
  belongs_to :subscriber,     -> { with_deleted }, polymorphic: true
  belongs_to :subscription,   -> { with_deleted }
  has_many   :line_items,     -> { with_deleted }, dependent: :destroy
  has_many   :charges,        -> { with_deleted }, dependent: :destroy

  # Validations
  validates :subscriber, presence: true

  # Callbacks
  after_touch :calculate_total

  # Scopes
  scope :paid,     -> { joins(:charges).where(charges: { status: Charge.statuses[:succeeded] }) }
  scope :past_due, -> { joins(:charges).where.not(charges: { status: Charge.statuses[:succeeded] }).where("subscription_id IS NULL AND due_at <= ?", Time.now) }

  monetize :total_cents

  # Calculates the final amount and attempts to charge the subscriber.
  # @return [Boolean] whether or not the charge is successful
  def finalize!
    calculate_total
    adjust_total unless self.finalized?

    charge = Charge.create(
      invoice:        self,
      payment_method: self.payment_method
    )

    if charge.succeeded?
      self.update_attribute(:paid, true)
      true
    else
      self.update_attribute(:paid, false)
      false
    end
  end

  # Returns whether or not the invoice has been finalized.
  # @return [Boolean]
  def finalized?
    self.charges.count > 0
  end

  # Returns the date for which the invoice was successfully paid
  # @return [Date] date of first successful charge, nil otherwise
  def paid_at
    return unless self.paid?
    self.charges.where(status: Charge.statuses[:succeeded]).chronological.first.created_at
  end

private

  # Adds an adjustment line item for adding/subtracting
  # the subscriber's account balance.
  def adjust_total
    return if self.subscriber.account_balance == 0 || self.total == 0

    if self.subscriber.account_balance > 0
      self.line_items << LineItem.create(
        amount:      self.subscriber.account_balance,
        description: "Previous Account Balance"
      )
    else
      available_credit = -self.subscriber.account_balance

      if available_credit >= self.total
        credit_used = self.total
      else
        credit_used = available_credit
      end

      self.subscriber.account_balance += credit_used
      self.subscriber.save

      self.line_items << LineItem.create(
        amount:      -credit_used,
        description: "Pay with Account Credit"
      )
    end

    calculate_total
  end

  # Calculates the new total for the invoice
  # @return [Boolean] true if saved
  def calculate_total
    self.reload
    return unless self.line_items.count > 0
    self.total = self.line_items.map(&:total).reduce(&:+)
    self.save
  end
end

class Charge < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :invoice,        -> { with_deleted }, touch: true
  belongs_to :payment_method, -> { with_deleted }, polymorphic: true

  scope :chronological, -> { order(created_at: :asc) }

  after_create :attempt_payment

  enum status: {
    failed:     0,
    succeeded:  1,
    errored:    2
  }

private

  def attempt_payment
    if self.invoice.total > 0
      begin
        self.payment_method.charge(self.invoice.total)
        self.succeeded!
      rescue Stripe::CardError => e
        self.error_message = e.json_body[:error][:message]
        self.failed!
      rescue Stripe::InvalidRequestError => e
        self.error_message = e.json_body[:error][:message]
        self.errored!
      rescue Stripe::AuthenticationError => e
        self.error_message = e.json_body[:error][:message]
        self.errored!
      rescue Stripe::APIConnectionError => e
        self.error_message = e.json_body[:error][:message]
        self.errored!
      rescue Stripe::StripeError => e
        self.error_message = e.json_body[:error][:message]
        self.errored!
      end
    else
      self.succeeded!
    end
  end
end

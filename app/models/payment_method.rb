class PaymentMethod < ActiveRecord::Base
  self.abstract_class = true

  # Relationships
  belongs_to :subscriber, polymorphic: true
  has_many   :subscriptions, -> { with_deleted }

  # Validations
  validates :subscriber,   presence: true

  # Callbacks
  before_destroy :check_for_current_subscriptions

private

  def check_for_current_subscriptions
    allow_destroy = true

    self.subscriptions.current.each do |subscription|
      allow_destroy = false if subscription.current?
    end

    allow_destroy
  end
end

class LineItem < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :invoice, -> { with_deleted }, touch: true

  monetize :amount_cents

  # Returns the calculated total for the line item
  # @return [Money] amount x quantity
  def total
    self.amount * self.quantity
  end
end

class ContactMessage < ActiveRecord::Base
  # Validations
  validates :email, :name, :message, presence: true

  # Callbacks
  after_create :deliver_email

private

  def deliver_email
    ContactMessageMailer.contact_email(self.id).deliver
  end
end

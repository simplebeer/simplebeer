class ContactMessageMailer < ActionMailer::Base
  include Sidekiq::Mailer
  default from: ENV["CONTACT_EMAIL_ADDRESS"]

  def contact_email(contact_message_id)
    @contact_message = ContactMessage.find_by_id(contact_message_id)

    if @contact_message && ENV["CONTACT_EMAIL_ADDRESS"]
      mail(
        to:      ENV["CONTACT_EMAIL_ADDRESS"],
        from:    @contact_message.email,
        subject: "[Simplebeer] New Contact Form Submission"
      )
    elsif @contact_message
      raise "Set the environment variable `CONTACT_EMAIL_ADDRESS` to enable the contact messages form."
    end
  end
end

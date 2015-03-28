ActionMailer::Base.smtp_settings = {
  :address        => ENV["SMTP_ADDRESS"],
  :port           => ENV["SMTP_PORT"],
  :authentication => :plain,
  :user_name      => ENV["SMTP_USER_NAME"],
  :password       => ENV["SMTP_PASSWORD"],
  :domain         => ENV["HOSTNAME"]
}

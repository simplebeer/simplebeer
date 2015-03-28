class HomeController < ApplicationController
  layout "home"
  skip_authorization_check

  def about
    @title = "About Us"
  end

  def contact
    @contact_message = ContactMessage.new

    @title = "Contact Us"
    @body_class = "contact-messages"
    render "contact_messages/new"
  end

  def features
    @title = "Features"
  end

  def index
    @hide_header = true
    @title = "Welcome"
  end

  def pricing
    @subscription_plans = SubscriptionPlan.active

    @title = "Pricing"
  end

  def privacy
    @title = "Privacy Policy"
  end

  def terms
    @title = "Terms of Service"
  end
end

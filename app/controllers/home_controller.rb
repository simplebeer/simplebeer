class HomeController < ApplicationController
  skip_authorization_check

  def index
  end

  def privacy
    @title = "Privacy Policy"
  end

  def subscribe
    @title = "Subscribe"
  end

  def terms
    @title = "Terms of Service"
  end
end

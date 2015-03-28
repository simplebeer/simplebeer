class HomeController < ApplicationController
  skip_authorization_check

  def index
    @title = "Welcome"
  end

  def privacy
    @title = "Privacy Policy"
  end

  def terms
    @title = "Terms of Service"
  end
end

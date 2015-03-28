module Admin
  class SessionsController < Devise::SessionsController
    skip_authorization_check

    def create
      @title = "Sign In"
      super
    end

    def new
      @title = "Sign In"
      super
    end
  end
end

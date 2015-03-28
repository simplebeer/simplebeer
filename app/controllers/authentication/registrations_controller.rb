module Authentication
  class RegistrationsController < Devise::RegistrationsController
    skip_authorization_check
    before_action :configure_permitted_parameters

    def create
      @title = "Sign Up"
      super
    end

    def new
      @title = "Sign Up"
      super
    end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) << [:name]
    end
  end
end

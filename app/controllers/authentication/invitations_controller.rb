module Authentication
  class InvitationsController < Devise::InvitationsController
    skip_authorization_check
    before_action :configure_permitted_parameters
    layout "home"

    def edit
      @title = "Join Organization"
      super
    end

    def update
      @title = "Join Organization"
      super
    end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:accept_invitation) << [:name, :subscription_plan_id]
    end
  end
end

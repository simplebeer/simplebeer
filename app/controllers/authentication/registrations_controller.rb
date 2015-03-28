module Authentication
  class RegistrationsController < Devise::RegistrationsController
    skip_authorization_check
    before_action :configure_permitted_parameters
    layout "home"

    def create
      @subscription_plan = SubscriptionPlan.find(params[:user][:subscription_plan_id])
      @title = "Sign Up ~ Account Information"
      super
    end

    def new
      if params[:subscription_plan_id]
        @title = "Sign Up ~ Account Information"
        @subscription_plan = SubscriptionPlan.find(params[:subscription_plan_id])
      else
        @title = "Sign Up ~ Select Plan"
        @body_class = "home pricing"
        @subscription_plans = SubscriptionPlan.active
      end

      super
    end

  protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:sign_up) << [:name, :subscription_plan_id]
    end
  end
end

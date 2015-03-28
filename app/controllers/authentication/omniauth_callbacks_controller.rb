module Authentication
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_authorization_check
    layout "home"

    before_action :set_omni_auth_provider

    def digitalocean
      @provider_name = "DigitalOcean"
      handle_callback
    end

    def facebook
      @provider_name = "Facebook"
      handle_callback
    end

    def github
      @provider_name = "GitHub"
      handle_callback
    end

    def google_oauth2
      @provider_name = "Google"
      handle_callback
    end

    def heroku
      @provider_name = "Heroku"
      handle_callback
    end

    def slack
      @provider_name = "Slack"
      handle_callback
    end

    def twitter
      @provider_name = "Twitter"
      handle_callback
    end

  private

    def handle_callback
      if current_user
        save_provider
      elsif @omni_auth_provider.persisted? && @omni_auth_provider.subscriber_type == "User"
        sign_in_user
      else
        redirect_to root_path, alert: "There was a problem connecting your #{@provider_name} account."
      end
    end

    def save_provider
      @omni_auth_provider.subscriber = current_user
      @omni_auth_provider.save
      redirect_to subscriber_omni_auth_providers_path(resource_name: "users", subscriber_id: current_user.id),
                  notice: "#{@provider_name} account connected successfully."
    end

    def set_omni_auth_provider
      @omni_auth_provider = OmniAuthProvider.where(
        name: request.env["omniauth.auth"]["provider"],
        uid:  request.env["omniauth.auth"]["uid"]
      ).first_or_initialize
      @omni_auth_provider.auth_data = request.env["omniauth.auth"]
    end

    def sign_in_user
      sign_in(:user, @omni_auth_provider.subscriber)
      redirect_to root_path, notice: "Signed in successfully."
    end
  end
end

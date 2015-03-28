class OmniAuthProvidersController < ApplicationController
  layout "account"

  def create
    @omni_auth_provider = OmniAuthProvider.new(omni_auth_provider_params)
    @omni_auth_provider.subscriber = current_user
    authorize! :create, @omni_auth_provider

    if @omni_auth_provider.save
      redirect_to subscriber_omni_auth_providers_path(
        resource_name: "users",
        subscriber_id: current_user.id
      ), notice: "Account connected successfully."
    else
      render @omni_auth_provider.name
    end
  end

  def destroy
    @omni_auth_provider = OmniAuthProvider.find(params[:id])
    authorize! :destroy, @omni_auth_provider

    @omni_auth_provider.destroy

    redirect_to subscriber_omni_auth_providers_path(
      resource_name: "users",
      subscriber_id: current_user.id
    ), notice: "Account disconnected successfully."
  end

  def index
    authorize! :read, OmniAuthProvider.new(subscriber: current_user)
    @title = "Connected Services ~ #{@subscriber.display_name}"
  end

  def new
    @omni_auth_provider = OmniAuthProvider.new(name: params[:provider], subscriber: current_user)
    authorize! :create, @omni_auth_provider

    render params[:provider]
  end

private

  def omni_auth_provider_params
    params.require(:omni_auth_provider).permit(
      :access_token,
      :email,
      :name
    )
  end
end

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_subscriber
  check_authorization

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, alert: exception.message
  end

private

  def set_subscriber
    if subscriber_route?
      @subscriber = params[:resource_name].classify.constantize.find(params[:subscriber_id])
      @organization = @subscriber if @subscriber.is_a?(Organization)
    else
      @subscriber = current_user
    end
  end

  def subscriber_route?
    params[:resource_name] && params[:subscriber_id]
  end
end

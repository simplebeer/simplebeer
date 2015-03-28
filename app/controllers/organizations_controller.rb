class OrganizationsController < ApplicationController
  layout "account"
  before_action :set_subscriber

  def create
    @organization = Organization.new(organization_params)
    authorize! :create, @organization

    if @organization.save
      organization_membership = @organization.add_user(current_user)
      organization_membership.role = :owner
      organization_membership.save
      redirect_to edit_organization_path(@organization), notice: "Organization created successfully"
    else
      @subscription_plans = SubscriptionPlan.organization.active
      @title = "New Organization ~ #{current_user.display_name}"
      @body_class = "#{@body_class} new"
      render :new
    end
  end

  def edit
    @organization = Organization.find(params[:id])
    authorize! :update, @organization

    @subscriber = @organization
    @title = "Account ~ #{@organization.name}"
  end

  def index
    authorize! :create, Organization
    @organization_memberships = current_user.organization_memberships.ordered_by_organization_name
    @title = "Organizations ~ #{current_user.display_name}"
  end

  def update
    @organization = Organization.find(params[:id])
    authorize! :update, @organization

    if @organization.update_attributes(organization_params)
      redirect_to edit_organization_path(@organization), notice: "Account updated successfully"
    else
      @title = "Account ~ #{@organization.name}"
      render :edit
    end
  end

  def new
    @organization = Organization.new
    authorize! :create, @organization

    @subscription_plans = SubscriptionPlan.organization.active
    @title = "New Organization ~ #{current_user.display_name}"
  end

  def url_options
    case params[:action].to_sym
    when :create, :new, :index
      { resource_name: "users", subscriber_id: current_user.id }.merge(super)
    else
      { resource_name: "organizations", subscriber_id: @organization.id }.merge(super)
    end
  end

private

  def organization_params
    params.require(:organization).permit(:name, :subscription_plan_id)
  end

  def set_subscriber
    @subscriber = current_user
  end

end

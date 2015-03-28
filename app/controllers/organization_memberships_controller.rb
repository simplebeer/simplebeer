class OrganizationMembershipsController < ApplicationController
  layout "account"
  before_action :build_organization_membership, only: [:new]
  before_action :set_organization
  before_action :set_organization_membership, only: [:destroy, :edit, :update]

  def create
    authorize! :create, OrganizationMembership.new(organization: @organization)
    @user = User.where(email: user_params[:email]).first_or_initialize

    if @user == current_user
      redirect_to subscriber_organization_memberships_path, notice: "You just tried to invite yourself!"
    elsif @user.persisted?
      add_existing_user
    else
      invite_new_user
    end
  end

  def destroy
    authorize! :destroy, @organization_membership
    @organization_membership.destroy

    redirect_to subscriber_organization_memberships_path, notice: "Membership removed successfully."
  end

  def edit
    authorize! :update, @organization_membership
    @title = "Edit Membership ~ #{@organization.display_name}"
  end

  def index
    @organization_memberships = @organization.memberships.ordered_by_user_name
    authorize! :update, @organization_memberships.first

    @title = "Users ~ #{@organization.display_name}"
  end

  def new
    authorize! :create, OrganizationMembership.new(organization: @organization)
    @title = "New User ~ #{@organization.display_name}"
  end

  def update
    authorize! :update, @organization_membership

    if @organization_membership.update_attributes(organization_membership_params)
      redirect_to subscriber_organization_memberships_path, notice: "Membership updated successfully."
    else
      @title = "Edit Membership ~ #{@organization.display_name}"
      render :edit
    end
  end

private

  def add_existing_user
    @organization_membership = @organization.add_user(@user)
    @organization_membership.role = organization_membership_params[:role]

    if @organization_membership.save
      redirect_to subscriber_organization_memberships_path, notice: "User added successfully."
    else
      @title = "New User ~ #{@organization.display_name}"
      render :new
    end
  end

  def build_organization_membership
    @organization_membership = OrganizationMembership.new(
      organization: @organization,
      user:         User.new
    )
  end

  def invite_new_user
    @organization_membership = OrganizationMembership.new(organization_membership_params)
    @organization_membership.user = User.invite!(user_params, current_user)
    if @organization_membership.save
      redirect_to subscriber_organization_memberships_path, notice: "User invited successfully."
    else
      @title = "New User ~ #{@organization.display_name}"
      render :new
    end
  end

  def organization_membership_params
    params.require(:organization_membership).permit(
      :role
    ).merge(
      organization_id: @organization.id
    )
  end

  def set_organization
    @organization = @subscriber
  end

  def set_organization_membership
    @organization_membership = OrganizationMembership.find(params[:id])
  end

  def user_params
    params[:organization_membership].require(:user).permit(:email).merge(subscription_plan_id: -1)
  end

end

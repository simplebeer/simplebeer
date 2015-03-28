class Ability
  include CanCan::Ability


  def initialize(user)
    @user ||= user
    @user ||= User.new # guest user (not logged in)

    # ------------------------------------------
    # ContactMessage Permissions
    # ------------------------------------------
    can :create, ContactMessage


    # ------------------------------------------
    # OmniAuthProvider Permissions
    # ------------------------------------------
    can :manage, OmniAuthProvider, subscriber_id: @user.id, subscriber_type: "User"


    # ------------------------------------------
    # Organization Permissions
    # ------------------------------------------

    # Single User Account Owner
    can :create, Organization

    # Organization Owner
    can :manage, Organization, id: owner_organizations_ids

    # Organization Admin
    can :read,   Organization, id: admin_organizations_ids
    can :update, Organization, id: admin_organizations_ids

    # Organization Member
    can :read, Organization, id: member_organizations_ids


    # ------------------------------------------
    # OrganizationMembership Permissions
    # ------------------------------------------

    # Organization Owner
    can :manage, OrganizationMembership, organization_id: owner_organizations_ids

    # Organization Admin
    can :manage, OrganizationMembership, organization_id: admin_organizations_ids


    # ------------------------------------------
    # PaymentMethod Permissions
    # ------------------------------------------

    payment_methods = [StripeCard]

    # Single User Account Owner
    can :manage, payment_methods, subscriber_id: @user.id, subscriber_type: "User"

    # Organization Owner
    can :manage, payment_methods, subscriber_id: owner_organizations_ids, subscriber_type: "Organization"

    # Organization Admin
    can :manage, payment_methods, subscriber_id: admin_organizations_ids, subscriber_type: "Organization"


    # ------------------------------------------
    # Subscription Permissions
    # ------------------------------------------

    # Single User Account Owner
    can :create, Subscription, subscriber_id: @user.id, subscriber_type: "User"
    can :update, Subscription, subscriber_id: @user.id, subscriber_type: "User"

    # Organization Owner
    can :update, Subscription, subscriber_id: owner_organizations_ids, subscriber_type: "Organization"
    can :create, Subscription, subscriber_id: owner_organizations_ids, subscriber_type: "Organization"

    # Organization Admin
    can :create, Subscription, subscriber_id: admin_organizations_ids, subscriber_type: "Organization"
    can :update, Subscription, subscriber_id: admin_organizations_ids, subscriber_type: "Organization"


    # ------------------------------------------
    # User Permissions
    # ------------------------------------------

    can :manage, User, id: @user.id
  end

private

  def admin_organization_memberships
    @admin_organization_memberships ||= @user.organization_memberships.where(user_id: @user.id, role: OrganizationMembership.roles[:admin])
  end

  def admin_organizations_ids
    @admin_membership_ids ||= admin_organization_memberships.pluck(:organization_id)
  end

  def member_organization_memberships
    @member_organization_memberships ||= @user.organization_memberships.where(user_id: @user.id, role: OrganizationMembership.roles[:member])
  end

  def member_organizations_ids
    @member_membership_ids ||= member_organization_memberships.pluck(:organization_id)
  end

  def owner_organization_memberships
    @owner_organization_memberships ||= @user.organization_memberships.where(user_id: @user.id, role: OrganizationMembership.roles[:owner])
  end

  def owner_organizations_ids
    @owner_membership_ids ||= owner_organization_memberships.pluck(:organization_id)
  end
end

class Organization < Subscriber
  acts_as_paranoid
  self.table_name = "organizations"

  # Relationships
  has_many :admin_invitations
  has_many :memberships, class_name: "OrganizationMembership"

  # Validations
  validates :name,                 presence: true
  validates :subscription_plan_id, presence: true, on: :create

  # Callbacks
  after_create :create_initial_subscription

  # Scopes
  scope :ordered_by_name, -> { order("LOWER(name)") }

  attr_accessor :subscription_plan_id

  # Add a user to the organization. Adding new users
  # does not give assign any roles/permissions.
  # @param user [User]
  # @return [OrganizationMembership]
  def add_user(user)
    # Check to see if the user has already been added
    membership = self.memberships.joins(:user).where(users: { id: user.id }).first
    return membership if membership

    membership = OrganizationMembership.create(
      organization: self,
      user:         user
    )

    self.memberships << membership
    self.reload # Make sure #users returns all users

    membership
  end

  # Alias for #name.to_s. Used to simplify displaying
  # User and Organization names when they share templates.
  # @return [String]
  def display_name
    self.name.to_s
  end

  # Memberships with the owner role, sorted by the user's name.
  # @return [Array<OrganizationMembership>]
  def owner_memberships
    self.memberships.owner.includes(:user).ordered_by_user_name
  end

  # The String representation of the organization.
  # @return [String]
  def to_s
    "#{self.class} ##{self.id} | #{self.name}"
  end

private

  # Subscribes the organization to the selected subscription plan.
  def create_initial_subscription
    return unless self.subscription_plan_id.to_i > 0

    @subscription_plan = SubscriptionPlan.find(self.subscription_plan_id)
    if @subscription_plan.organization?
      self.subscribe_to_plan(@subscription_plan)
    else
      raise ArgumentError, "The subscription plan with ID `#{subscription_plan_id}` is not for organization accounts"
    end
  end
end

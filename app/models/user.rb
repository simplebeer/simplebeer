class User < Subscriber
  acts_as_paranoid
  self.table_name = "users"

  # Devise Modules
  # - Also available: :confirmable, :lockable, and :timeoutable
  devise :async, :database_authenticatable, :invitable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, omniauth_providers: [
    :codeship,
    :digitalocean,
    :dnsimple,
    :facebook,
    :github,
    :google_oauth2,
    :heroku,
    :slack,
    :twitter
  ]

  # Relationships
  has_many :organization_memberships
  has_many :organizations, through: :organization_memberships

  # Validations
  validates :name,                 presence: true
  validates :subscription_plan_id, presence: true, on: :create

  # Callbacks
  after_create :create_initial_subscription

  # Scopes
  scope :ordered_by_name, -> { order("LOWER(name)") }

  attr_accessor :subscription_plan_id

  # Returns whether or not the user can perform
  # an action on a subject based on roles/permissions.
  # @param action [Symbol]
  # @param subject [Object]
  def can?(action, subject, *args)
    ability = Ability.new(self)
    ability.can?(action, subject, *args)
  end

  # Returns the name to be displayed for the user. The user's name will be
  # returned if it exists and will fall back to the user's email address.
  # @return [String]
  def display_name
    self.name.blank? ? self.email : self.name
  end

  # The String representation of the user.
  # @return [String]
  def to_s
    "#{self.class} ##{self.id} | #{self.name.blank? ? self.email : "#{self.name} <#{self.email}>"}"
  end

private

  # Subscribes the user to the selected subscription plan.
  def create_initial_subscription
    return unless self.subscription_plan_id.to_i > 0

    @subscription_plan = SubscriptionPlan.find(self.subscription_plan_id)
    if @subscription_plan.user?
      self.subscribe_to_plan(@subscription_plan)
    else
      create_organization_and_subscription_plan
    end
  end

  # Creates an organization when the user chooses an organization plan on sign up.
  def create_organization_and_subscription_plan
    organization = Organization.create(
      name:                 "My Organization",
      subscription_plan_id: self.subscription_plan_id,
      time_zone:            self.time_zone
    )

    organization_membership = organization.add_user(self)
    organization_membership.role = :owner
    organization_membership.save
  end

end

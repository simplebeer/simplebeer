# ------------------------------------------
# Single User Plans
# ------------------------------------------

SubscriptionPlan.create(
  name:              "Free",
  color:             "#7eb1c9",
  active:            true,
  price:             Money.new(0, "USD"), # Free
  account_type:      :user,
  interval:          :month,
  interval_count:    1,
  trial_period_days: 0,
  reference_code:    "user-free-09-2014"
)

SubscriptionPlan.create(
  name:              "Value",
  color:             "#98c981",
  active:            true,
  price:             Money.new(900, "USD"), # $9.00
  account_type:      :user,
  interval:          :month,
  interval_count:    1,
  trial_period_days: 30,
  reference_code:    "user-value-09-2014"
)

SubscriptionPlan.create(
  name:              "Pro",
  color:             "#595b68",
  active:            true,
  price:             Money.new(5900, "USD"), # $59.00
  account_type:      :user,
  interval:          :month,
  interval_count:    1,
  trial_period_days: 30,
  reference_code:    "user-pro-09-2014"
)

# ------------------------------------------
# Organization Plans
# ------------------------------------------

SubscriptionPlan.create(
  name:              "Small",
  color:             "#7c8cc8",
  active:            true,
  price:             Money.new(3900, "USD"), # $39.00
  account_type:      :organization,
  interval:          :month,
  interval_count:    1,
  trial_period_days: 30,
  reference_code:    "organization-small-09-2014"
)

SubscriptionPlan.create(
  name:              "Medium",
  color:             "#c87c7f",
  active:            true,
  price:             Money.new(9900, "USD"), # $99.00
  account_type:      :organization,
  interval:          :month,
  interval_count:    1,
  trial_period_days: 30,
  reference_code:    "organization-medium-09-2014"
)

SubscriptionPlan.create(
  name:              "Large",
  color:             "#80c9ae",
  active:            true,
  price:             Money.new(19900, "USD"), # $199.00
  account_type:      :organization,
  interval:          :month,
  interval_count:    1,
  trial_period_days: 30,
  reference_code:    "organization-large-09-2014"
)

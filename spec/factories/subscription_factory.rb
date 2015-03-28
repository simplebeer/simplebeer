# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :subscription do
    association :subscriber, factory: :organization
    association :plan,       factory: :subscription_plan

    auto_renew           true
    current_period_start { Time.now }
    current_period_end   { Time.now + 1.month }
    trial_ends_at        { Time.now - 30.days }
    cancel_at_period_end false
    status               :active

    factory :trial_subscription do
      current_period_end   { Time.now + 14.days }
      trial_ends_at        { Time.now + 14.days }
      status               :trialing
    end
  end
end

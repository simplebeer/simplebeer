# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invoice do
    association :subscriber, factory: :organization

    due_at { Time.now }
  end
end

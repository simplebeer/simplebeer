# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :organization_membership do
    organization
    user

    trait :with_admin_role do
      role :admin
    end
  end
end

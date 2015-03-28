# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email     { Faker::Internet.email }
    name      { Faker::Name.first_name }
    password  "password123"
    time_zone { Faker::Address.time_zone }

    subscription_plan_id { create(:subscription_plan).id }
  end
end

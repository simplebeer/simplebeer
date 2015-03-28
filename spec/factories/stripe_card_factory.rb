# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stripe_card do
    association :subscriber, factory: :user
    brand          "Visa"
    exp_month      10
    exp_year       20
    last4          "1234"
    stripe_card_id "card123"
    stripe_token   "abc123"
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :charge do
    invoice

    factory :successful_charge do
      after(:create) do |charge|
        charge.succeeded!
      end
    end

    factory :unsuccessful_charge do
      after(:create) do |charge|
        charge.failed!
      end
    end
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :single_line_item, class: LineItem do
    quantity 1
    description "MyString"
    amount Money.new(1999, "USD") # $19.99 USD
  end

  factory :multiplied_line_item, class: LineItem do
    quantity 5
    description "MyString"
    amount Money.new(1999, "USD") # $19.99 USD
  end
end

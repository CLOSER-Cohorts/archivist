FactoryBot.define do
  factory :code do
    sequence(:value) { |n| "code_value_#{n}" }
    association :code_list
    association :category
  end
end
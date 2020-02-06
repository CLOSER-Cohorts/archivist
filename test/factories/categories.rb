FactoryBot.define do
  factory :category do
    sequence(:label) { |n| "Category ##{n}" }
    instrument
  end
end

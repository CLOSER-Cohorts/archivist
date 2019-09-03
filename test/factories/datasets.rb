FactoryBot.define do
  factory :dataset do
    sequence(:name) { |n| "Dataset #{n}" }
    sequence(:study) { |n| "Study#{n}" }
  end
end

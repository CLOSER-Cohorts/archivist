FactoryBot.define do
  factory :code_list do
    sequence(:label) { |n| "Code List ##{n}" }
    instrument
  end
end

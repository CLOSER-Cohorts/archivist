FactoryBot.define do
  factory :instrument do
    sequence(:label) { |n| "Label #{n}" }
    sequence(:agency) { |n| "Agency#{n}" }
    sequence(:prefix) { |n| "prefix_#{n}" }
    sequence(:study) { |n| "Study#{n}" }
    version { '1.0' }
  end
end

FactoryBot.define do
  factory :dataset do
    sequence(:name) { |n| "Dataset #{n}" }
    sequence(:study) { |n| "Study#{n}" }
    sequence(:filename) { |n| "study_#{n}.ddi32.rp.xml" }
  end
end

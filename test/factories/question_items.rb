FactoryBot.define do
  factory :question_item do
    sequence(:label) { |n| "Label ##{n}" }
    sequence(:literal) { |n| "Literal #{n}" }
    question_type { 'QuestionItem'}
    instrument
  end
end

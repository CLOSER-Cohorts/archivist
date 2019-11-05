FactoryBot.define do
  factory :question_grid do
    sequence(:label) { |n| "Label ##{n}" }
    sequence(:literal) { |n| "Literal #{n}" }
    question_type { 'QuestionGrid'}
    instrument
    horizontal_code_list factory: :code_list
    vertical_code_list factory: :code_list
  end
end

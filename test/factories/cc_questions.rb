FactoryBot.define do
  factory :cc_question do
    association :question, factory: :question_item
    response_unit
    topic
    sequence(:label) { |n| "q_#{n}" }
    instrument { Instrument.first }
  end
end

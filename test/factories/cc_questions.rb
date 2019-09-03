FactoryBot.define do
  factory :cc_question do
    association :question, factory: :question_item
    response_unit
    topic
    instrument { Instrument.first }
  end
end

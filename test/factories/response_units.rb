FactoryBot.define do
  factory :response_unit do
    sequence(:label) {|n| "Response Unit Label ##{n}"}
    instrument { Instrument.first }
  end
end

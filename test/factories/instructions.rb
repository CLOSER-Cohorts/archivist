FactoryBot.define do
  factory :instruction do
    instrument { Instrument.first }
  end
end

FactoryBot.define do
  factory :cc_loop do
    sequence(:label) { |n| "l_#{n}" }
    instrument { Instrument.first }
    loop_var { 'loop1' }
    start_val { 1 }
    sequence(:ddi_slug) { |n| "#{n}001" }
  end
end

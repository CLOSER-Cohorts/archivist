FactoryBot.define do
  factory :map do
    association(:source, factory: :cc_question)
    variable
  end
end

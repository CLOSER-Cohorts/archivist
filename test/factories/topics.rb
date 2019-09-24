FactoryBot.define do
  factory :topic do
    sequence(:name) {|n| "Topic ##{n}"}
    sequence(:code) {|n| n.to_s }
  end
end

FactoryBot.define do
  factory :import do
    dataset
    import_type { "ImportJob::TopicV" }
  end
end

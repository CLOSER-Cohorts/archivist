FactoryBot.define do
  factory :export do
    export_type { 'default' } # Adjust this to a default export type relevant to your app
    state { 'pending' } # Default state; adjust based on job progress
    log { '[]' } # Default to an empty JSON array; ensure it matches the type expected

    # Associations
    document { nil } # Optional, as `null: true` in migration
    dataset { nil } # Optional, as `null: true` in migration
    instrument { nil } # Optional, as `null: true` in migration

    # Add traits for specific scenarios
    trait :with_document do
      association :document
    end

    trait :with_dataset do
      association :dataset
    end

    trait :with_instrument do
      association :instrument
    end

    trait :running do
      state { 'running' }
    end

    trait :success do
      state { 'success' }
    end

    trait :failure do
      state { 'failure' }
    end
  end
end
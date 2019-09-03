FactoryBot.define do
  factory :variable do
    sequence(:name) { |n| "var#{n}" }
    sequence(:label) { |n| "Variable Label #{n}" }
    var_type { 'Normal' }
    dataset

    # user_with_questions will create post data after the user has been created
    factory :variable_with_questions do
      # questions_count is declared as a transient attribute and available in
      # attributes on the factory, as well as the callback via the evaluator
      transient do
        questions_count { 1 }
      end

      # the after(:create) yields two values; the user instance itself and the
      # evaluator, which stores all values from the factory, including transient
      # attributes; `create_list`'s second argument is the number of records
      # to create and we make sure the user is associated properly to the post
      after(:create) do |variable, evaluator|
        create_list(:map, evaluator.questions_count, variable: variable, source: FactoryBot.create(:cc_question))
      end
    end
  end
end

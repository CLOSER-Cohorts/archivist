json.array!(@cc_questions) do |cc_question|
  json.extract! cc_question, :id, :question_id, :question_type
  json.label cc_question.label
end

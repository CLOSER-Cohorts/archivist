json.array!(@collection) do |cc_question|
  json.extract! cc_question, :id, :question_id, :question_type, :position
  json.label cc_question.label
end

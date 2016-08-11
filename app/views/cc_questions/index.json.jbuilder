json.array!(@collection) do |cc_question|
  json.extract! cc_question, :id, :question_id, :question_type, :position, :response_unit_id
  json.label cc_question.label
  json.parent cc_question.parent_id
end

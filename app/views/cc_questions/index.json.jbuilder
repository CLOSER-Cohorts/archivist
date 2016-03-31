json.array!(@collection) do |cc_question|
  json.extract! cc_question, :id, :question_id, :question_type, :position, :response_unit_id
  json.label cc_question.label
  json.parent cc_question.parent.id
  json.variables cc_question.variables
  json.topic cc_question.topic
end

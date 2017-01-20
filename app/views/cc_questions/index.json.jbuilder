json.array!(@collection) do |cc_question|
  json.extract! cc_question, :id, :question_id, :question_type, :position, :response_unit_id
  json.label cc_question.label
  # json.variables cc_question.variables
  json.topic cc_question.topic
  json.parent cc_question.parent_id
  json.base_label cc_question.base_label
  json.response_unit_label cc_question.response_unit_label
end

json.array!(@collection) do |cc_question|
  json.extract! cc_question, :id, :question_id, :question_type, :position, :branch, :response_unit_id
  json.label cc_question.label
  json.variables cc_question.variables, :id, :name, :label
  json.topic cc_question.topic
  json.ancestral_topic cc_question.get_ancestral_topic, :id, :code, :name, :parent_id unless cc_question.topic.nil?
  json.parent_id cc_question.parent_id
  json.parent_type cc_question.parent_type
  json.base_label cc_question.base_label
  json.response_unit_label cc_question.response_unit_label
  json.resolved_topic cc_question.resolved_topic
  json.variable_topic cc_question.variable_topics.first
  json.errors cc_question.errors.full_messages.to_sentence unless cc_question.valid?
end

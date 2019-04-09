json.array!(@collection) do |cc_question|
  json.extract! cc_question, :id, :question_id, :question_type, :position, :branch, :response_unit_id
  json.label cc_question.label
  json.variables cc_question.variables, :id, :name, :label
  json.topic cc_question.topic
  json.strand do
    json.topic cc_question.topic
    json.good cc_question.strand.good
  end unless cc_question.strand.topic.nil?
  json.suggested_topic cc_question.get_suggested_topic, :id, :code, :name, :parent_id unless cc_question.get_suggested_topic.nil?
  json.ancestral_topic cc_question.topic, :id, :code, :name, :parent_id unless cc_question.topic.nil?
  json.parent_id cc_question.parent_id
  json.parent_type cc_question.parent_type
  json.base_label cc_question.base_label
  json.response_unit_label cc_question.response_unit_label
end

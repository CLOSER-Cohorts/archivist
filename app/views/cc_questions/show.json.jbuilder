json.extract! @object, :id, :question_id, :question_type, :position, :branch, :response_unit_id
json.label @object.label
json.parent_id @object.parent_id
json.parent_type @object.parent_type
json.base_label @object.base_label
json.response_unit_label @object.response_unit_label
json.variables @object.variables, :id, :name, :label
json.topic @object.topic
json.strand do
  json.topic @object.topic
  json.good @object.strand.good
end unless @object.strand.topic.nil?
json.suggested_topic @object.get_suggested_topic, :id, :code, :name, :parent_id unless @object.get_suggested_topic.nil?
json.ancestral_topic @object.get_ancestral_topic, :id, :code, :name, :parent_id unless @object.get_ancestral_topic.nil?
json.type 'CcQuestion'

json.extract! @object, :id, :question_id, :question_type, :position, :response_unit_id
json.label @object.label
json.parent @object.parent.id
json.base_label @object.base_label
json.response_unit_label @object.response_unit_label
json.variables @object.variables, :id, :name, :label
json.topic @object.topic
json.strand do
  json.topic do
    json.id = @object.strand.topic.id
    json.code = @object.strand.topic.code
    json.name = @object.strand.topic.name
    json.parent_id = @object.strand.topic.parent_id
  end
  json.good @object.strand.good
end unless @object.strand.topic.nil?
json.suggested_topic @object.get_suggested_topic, :id, :code, :name, :parent_id unless @object.get_suggested_topic.nil?
json.ancestral_topic @object.get_ancestral_topic, :id, :code, :name, :parent_id unless @object.get_ancestral_topic.nil?
json.type 'CcQuestion'
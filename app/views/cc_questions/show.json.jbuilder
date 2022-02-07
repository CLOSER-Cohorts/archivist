# frozen_string_literal: true

json.extract! @object, :id, :question_id, :question_type, :position, :branch, :response_unit_id
json.label @object.label
json.parent_id @object.parent_id
json.parent_type @object.parent_type
json.base_label @object.base_label
json.response_unit_label @object.response_unit_label
json.variables @object.maps do | map |
  json.id map.variable_id
  json.name map.variable.name
  json.label map.variable.label
  json.x map.x
  json.y map.y
end
json.topic @object.topic
json.ancestral_topic @object.get_ancestral_topic, :id, :code, :name, :parent_id unless @object.topic.nil?
json.variable_topic @object.variable_topics.first
json.type 'CcQuestion'

json.extract! @object, :id, :question_id, :question_type, :position, :response_unit_id
json.label @object.label
json.parent @object.parent.id
json.base_label @object.base_label
json.response_unit_label @object.response_unit_label
json.variables @object.variables, :id, :name, :label
json.topic @object.topic

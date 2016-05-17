json.extract! @object, :id, :question_id, :question_type, :position, :response_unit_id
json.label @object.label
json.parent @object.parent.id
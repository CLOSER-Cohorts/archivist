json.extract! @object, :id, :name, :study
json.variables @object.variables.count
json.questions @object.questions, :id, :label, :topic

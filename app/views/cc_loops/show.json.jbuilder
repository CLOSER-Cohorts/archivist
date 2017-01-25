json.extract! @object, :id, :loop_var, :start_val, :end_val, :loop_while, :position
json.label @object.label
json.children @object.children do |child|
  json.id child.construct.id
  json.type child.construct.class.name
end
json.parent @object.parent.id
json.topic @object.topic
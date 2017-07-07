json.extract! @object, :id, :loop_var, :start_val, :end_val, :loop_while, :position
json.label @object.label
json.children @object.children do |child|
  json.id child.id
  json.type child.class.name
end
json.parent @object.parent.id
json.topic @object.topic || @object.find_closest_ancestor_topic
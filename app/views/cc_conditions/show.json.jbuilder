json.extract! @object, :id, :literal, :logic, :position
json.label @object.label
json.children @object.children do |child|
  json.id child.id
  json.type child.class.name
end
json.fchildren @object.fchildren do |child|
  json.id child.id
  json.type child.class.name
end
json.parent_id @object.parent_id
json.parent_type @object.parent_type
json.topic @object.topic || @object.find_closest_ancestor_topic

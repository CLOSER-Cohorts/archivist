json.extract! @object, :id, :literal, :logic, :position
json.label @object.label
json.children @object.children.where(branch: 0) do |child|
  json.id child.construct.id
  json.type child.construct.class.name
end
json.fchildren @object.children.where(branch: 1) do |child|
  json.id child.construct.id
  json.type child.construct.class.name
end
json.parent @object.parent.id
json.topic @object.topic

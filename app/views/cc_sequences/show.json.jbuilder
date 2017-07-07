json.extract! @object, :id, :literal, :position
json.label @object.label
json.children @object.children do |child|
  json.id child.id
  json.type child.class.name
end
json.top @object.is_top?
unless @object.parent.nil?
  json.parent @object.parent.id
end
json.topic @object.topic || @object.find_closest_ancestor_topic

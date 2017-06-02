json.extract! @object, :id, :literal, :position
json.label @object.label
json.children @object.children do |child|
  json.id child.construct.id
  json.type child.construct.class.name
end
json.top @object.parent.nil?
unless @object.parent.nil?
  json.parent @object.parent.id
end
json.topic @object.topic || @object.get_ancestral_topic

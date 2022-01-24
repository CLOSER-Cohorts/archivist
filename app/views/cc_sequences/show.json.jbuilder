# frozen_string_literal: true

json.extract! @object, :id, :literal, :position, :branch
json.label @object.label
json.children @object.construct_children
json.top @object.is_top?
unless @object.parent.nil?
  json.parent_id @object.parent_id
  json.parent_type @object.parent_type
end
json.topic @object.topic || @object.find_closest_ancestor_topic

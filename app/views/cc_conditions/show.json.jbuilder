json.extract! @object, :id, :literal, :logic, :position, :branch
json.label @object.label
json.children @object.construct_children 0
json.fchildren @object.construct_children 1
json.parent_id @object.parent_id
json.parent_type @object.parent_type
json.topic @object.topic || @object.find_closest_ancestor_topic

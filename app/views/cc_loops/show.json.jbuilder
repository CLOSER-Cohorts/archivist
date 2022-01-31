# frozen_string_literal: true

json.extract! @object, :id, :loop_var, :start_val, :end_val, :loop_while, :position, :branch
json.label @object.label
json.children @object.construct_children
json.parent_id @object.parent_id
json.parent_type @object.parent_type
json.topic @object.topic || @object.find_closest_ancestor_topic
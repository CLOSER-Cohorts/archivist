# frozen_string_literal: true

json.array!(@collection) do |cc_condition|
  json.extract! cc_condition, :id, :literal, :logic, :position, :branch
  json.label cc_condition.label
  json.children cc_condition.construct_children 0
  json.fchildren cc_condition.construct_children 1
  json.parent_id cc_condition.parent_id
  json.parent_type cc_condition.parent_type
  json.topic cc_condition.topic || cc_condition.find_closest_ancestor_topic
end

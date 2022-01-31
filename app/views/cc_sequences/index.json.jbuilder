# frozen_string_literal: true

json.array! @collection.includes(:topic) do |cc_sequence|
  json.extract! cc_sequence, :id, :literal, :position, :branch
  json.label cc_sequence.label
  json.children cc_sequence.construct_children
  json.top cc_sequence.is_top?
  json.parent_id cc_sequence.parent_id
  json.parent_type cc_sequence.parent_type
  json.topic cc_sequence.topic || cc_sequence.find_closest_ancestor_topic
end

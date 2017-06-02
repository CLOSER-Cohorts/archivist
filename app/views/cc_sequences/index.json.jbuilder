json.array! @collection do |cc_sequence|
  json.extract! cc_sequence, :id, :literal, :position
  json.label cc_sequence.label
  json.children cc_sequence.construct_children
  json.top cc_sequence.is_top?
  json.parent cc_sequence.parent_id
  json.topic cc_sequence.topic || cc_sequence.get_ancestral_topic
end

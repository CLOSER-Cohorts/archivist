json.array!(@collection) do |cc_sequence|
  json.extract! cc_sequence, :id, :literal, :position
  json.label cc_sequence.label
  json.children cc_sequence.children do |child|
    json.id child.construct.id
    json.type child.construct.class.name
  end
  json.top cc_sequence.parent.nil?
  unless cc_sequence.parent.nil?
    json.parent cc_sequence.parent.id
  end
end

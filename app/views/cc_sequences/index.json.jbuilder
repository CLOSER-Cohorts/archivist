json.array!(@cc_sequences) do |cc_sequence|
  json.extract! cc_sequence, :id, :literal, :position
  json.label cc_sequence.label
  json.children cc_sequence.children do |child|
    json.id child.construct.id
    json.type child.construct.class.name
  end
  json.top cc_sequence.parent.nil?
end

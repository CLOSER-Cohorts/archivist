json.array!(@cc_sequences) do |cc_sequence|
  json.extract! cc_sequence, :id, :literal
  json.url cc_sequence_url(cc_sequence, format: :json)
end

json.array!(@collection) do |cc_question|
  json.id cc_question.id
  json.label cc_question.label
end

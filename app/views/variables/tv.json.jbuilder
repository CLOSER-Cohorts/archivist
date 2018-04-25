json.array!(@collection) do |v|
  json.variable v.name
  json.topic = v.fully_resolved_topic_code
end

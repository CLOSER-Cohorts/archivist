json.array!(@collection) do |qc|
  json.question qc.name
  json.topic = qc.fully_resolved_topic_code
end

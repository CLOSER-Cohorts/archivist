json.array!(@topics) do |topic|
  json.extract! topic, :id, :name, :parent_id, :code
  json.url topic_url(topic, format: :json)
end

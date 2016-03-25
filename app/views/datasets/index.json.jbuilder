json.array!(@collection) do |dataset|
  json.extract! dataset, :id, :name
  json.url dataset_url(dataset, format: :json)
end

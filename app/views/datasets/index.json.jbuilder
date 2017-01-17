json.array!(@collection) do |dataset|
  json.extract! dataset, :id, :name
end

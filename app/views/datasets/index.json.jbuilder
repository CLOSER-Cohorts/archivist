json.array!(@collection) do |dataset|
  json.extract! dataset, :id, :name
  json.variables dataset.var_count
end

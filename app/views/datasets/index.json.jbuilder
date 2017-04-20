json.array!(@collection) do |dataset|
  json.extract! dataset, :id, :name, :study, :filename
  json.variables dataset.var_count
end

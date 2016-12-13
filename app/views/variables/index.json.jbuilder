json.array!(@collection) do |variable|
  json.extract! variable, :id, :name, :label, :var_type, :dataset_id
end

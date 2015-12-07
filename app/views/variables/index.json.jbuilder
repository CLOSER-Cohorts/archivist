json.array!(@variables) do |variable|
  json.extract! variable, :id, :name, :label, :var_type, :dataset_id
  json.url variable_url(variable, format: :json)
end

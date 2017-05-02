json.array!(@collection) do |dataset|
  json.extract! dataset, :id, :name, :study, :filename
  json.dvs dataset.dv_count
  json.qvs dataset.qv_count
  json.variables dataset.var_count
end

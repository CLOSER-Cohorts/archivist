json.array!(@collection) do |response_domain_numeric|
  json.extract! response_domain_numeric, :id, :numeric_type, :label, :min, :max
end

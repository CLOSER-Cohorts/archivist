json.array!(@response_domain_numerics) do |response_domain_numeric|
  json.extract! response_domain_numeric, :id, :numeric_type, :label, :min, :max
  json.url response_domain_numeric_url(response_domain_numeric, format: :json)
end

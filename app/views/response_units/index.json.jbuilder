json.array!(@response_units) do |response_unit|
  json.extract! response_unit, :id, :label
  json.url response_unit_url(response_unit, format: :json)
end

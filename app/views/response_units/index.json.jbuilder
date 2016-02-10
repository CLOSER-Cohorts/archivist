json.array!(@response_units) do |response_unit|
  json.extract! response_unit, :id, :label
end

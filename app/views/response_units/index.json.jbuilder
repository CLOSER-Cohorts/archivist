json.array!(@collection) do |response_unit|
  json.extract! response_unit, :id, :label
end

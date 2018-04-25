json.array!(@collection) do |category|
  json.extract! category, :id, :label
end

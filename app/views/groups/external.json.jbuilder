json.array!(@collection) do |group|
  json.extract! group, :id, :label
end

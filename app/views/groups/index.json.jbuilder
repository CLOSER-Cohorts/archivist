json.array!(@collection) do |group|
  json.extract! group, :id, :label, :group_type, :study
end

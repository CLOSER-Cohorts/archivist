json.array!(@categories) do |category|
  json.extract! category, :id, :label
end

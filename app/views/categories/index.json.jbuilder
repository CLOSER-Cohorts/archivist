json.array!(@categories) do |category|
  json.extract! category, :id, :label
  json.url category_url(category, format: :json)
end

json.array!(@cc_conditions) do |cc_condition|
  json.extract! cc_condition, :id, :literal, :logic
  json.url cc_condition_url(cc_condition, format: :json)
end

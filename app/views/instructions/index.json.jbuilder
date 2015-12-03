json.array!(@instructions) do |instruction|
  json.extract! instruction, :id, :text
  json.url instruction_url(instruction, format: :json)
end

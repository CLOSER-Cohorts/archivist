json.array!(@question_items) do |question_item|
  json.extract! question_item, :id, :label, :literal, :instruction_id
  json.url question_item_url(question_item, format: :json)
end

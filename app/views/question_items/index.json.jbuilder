json.array!(@question_items) do |question_item|
  json.extract! question_item, :id, :label, :literal, :instruction_id
  json.rds question_item.response_domains do |rd|
    json.partial! 'response_domains/show', rd: rd
  end
  json.url question_item_url(question_item, format: :json)
end

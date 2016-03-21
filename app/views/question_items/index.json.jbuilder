json.array!(@collection) do |question_item|
  json.extract! question_item, :id, :label, :literal, :instruction_id
  json.type question_item.class.name
  json.rds question_item.response_domains do |rd|
    json.partial! 'response_domains/show', rd: rd
  end
end

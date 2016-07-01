json.array!(@collection) do |question_item|
  json.extract! question_item, :id, :label, :literal
  json.type question_item.class.name
  json.instruction question_item.instruction.nil? ? '' : question_item.instruction.text
  json.rds question_item.response_domains do |rd|
    json.partial! 'response_domains/show', rd: rd
  end
end

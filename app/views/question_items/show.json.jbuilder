json.extract! @object, :id, :label, :literal, :instruction_id, :created_at, :updated_at
json.type @object.class.name
json.instruction @object.instruction
json.rds @object.response_domains do |rd|
  json.partial! 'response_domains/show', rd: rd
end
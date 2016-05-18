json.extract! @object, :id, :label, :literal, :vertical_code_list_id, :horizontal_code_list_id, :roster_rows, :roster_label, :corner_label, :created_at, :updated_at
json.type @object.class.name
json.instruction @object.instruction
json.rds @object.response_domains do |rd|
  json.partial! 'response_domains/show', rd: rd
end
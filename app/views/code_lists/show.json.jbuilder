# frozen_string_literal: true

json.extract! @object, :id, :label, :created_at, :updated_at
json.type 'CodeList'
json.codes @object.codes do |code|
  json.id code.id
  json.category_id code.category.id
  json.value code.value
  json.order code.order
  json.label code.label
end
json.rd !@object.response_domain.nil?
unless @object.response_domain.nil?
  json.min_responses @object.response_domain.min_responses
  json.max_responses @object.response_domain.max_responses
end
json.used_by @object.used_by do |obj|
  json.type obj.class.name
  json.id obj.id
  json.label obj.label
end

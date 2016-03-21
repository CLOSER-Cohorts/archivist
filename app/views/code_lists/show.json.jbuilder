json.extract! @object, :id, :label, :created_at, :updated_at
json.codes @object.codes do |code|
  json.id code.id
  json.category_id code.category.id
  json.value code.value
  json.order code.order
  json.label code.label
end
json.rd !@object.response_domain.nil?
if @object.response_domain.nil?
  json.used_by []
else
  json.used_by @object.used_by do |obj|
    json.type obj.class.name
    json.id obj.id
    json.label obj.label
  end
end

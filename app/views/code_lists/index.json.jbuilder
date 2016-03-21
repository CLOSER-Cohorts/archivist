json.array!(@collection) do |code_list|
  json.extract! code_list, :id, :label
  json.type code_list.class.name
  json.codes code_list.codes do |code|
    json.id code.id
    json.category_id code.category.id
    json.value code.value
    json.order code.order
  end
  json.rd !code_list.response_domain.nil?
  if code_list.response_domain.nil?
    json.used_by []
  else
    json.used_by code_list.used_by do |obj|
      json.type obj.class.name
      json.id obj.id
      json.label obj.label
    end
  end
end

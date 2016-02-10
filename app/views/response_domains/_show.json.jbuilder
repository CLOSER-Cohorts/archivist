if not rd.nil?
  json.type rd.class.name
  json.label rd.label
  if rd.class == ResponseDomainCode
    json.codes rd.code_list.codes do |code|
      json.label code.category.label
      json.value code.value
      json.order code.order
    end
  end
end
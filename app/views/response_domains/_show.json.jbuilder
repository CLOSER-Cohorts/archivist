unless rd.nil?
  json.id rd.id
  json.type rd.class.name
  json.label rd.label
  if rd.class == ResponseDomainCode
    json.min_responses rd.min_responses
    json.max_responses rd.max_responses
    json.codes rd.codes, :label, :value, :order
  else
    json.subtype rd.subtype
    json.params rd.params
  end
end
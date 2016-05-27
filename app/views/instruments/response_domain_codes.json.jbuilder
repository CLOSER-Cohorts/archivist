json.array! @object.response_domain_codes do |rd|
  json.id rd.id
  json.type rd.class.name
  json.label rd.label
end
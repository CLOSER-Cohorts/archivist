json.array! @object.response_domains do |rd|
  json.id rd.id
  json.type rd.class.name
  json.label rd.label
  if rd.class.name == 'ResponseDomainDatetime'
    json.subtype rd.datetime_type
    json.format rd.format
  end
  if rd.class.name == 'ResponseDomainNumeric'
    json.subtype rd.numeric_type
    json.min rd.min
    json.max rd.max
  end
  if rd.class.name == 'ResponseDomainText'
    json.maxlen rd.maxlen
  end
end
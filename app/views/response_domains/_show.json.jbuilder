if not rd.nil?
  json.id rd.id
  json.type rd.class.name
  json.label rd.label
  if rd.class == ResponseDomainCode
    json.codes rd.code_list.codes do |code|
      json.label code.category.label
      json.value code.value
      json.order code.order
    end
  end
  if rd.class == ResponseDomainDatetime
    json.subtype rd.datetime_type
    json.params '(' + rd.format.to_s + ')'
  end
  if rd.class == ResponseDomainNumeric
    json.subtype rd.numeric_type
    json.params '(' + (rd.min.nil? ? '~' : '%g' % rd.min) + ',' + (rd.max.nil? ? '~' : '%g' % rd.max) + ')'
  end
  if rd.class == ResponseDomainText
    json.params rd.maxlen.nil? ? '' : '(' + '%g' % rd.maxlen + ')'
  end
end
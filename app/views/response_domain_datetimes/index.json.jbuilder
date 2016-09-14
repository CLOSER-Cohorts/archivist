json.array!(@collection) do |response_domain_datetime|
  json.extract! response_domain_datetime, :id, :label, :format
  json.subtype response_domain_datetime.datetime_type
  json.type 'ResponseDomainDatetime'
end

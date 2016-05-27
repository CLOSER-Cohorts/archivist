json.array!(@collection) do |response_domain_datetime|
  json.extract! response_domain_datetime, :id, :datetime_type, :label, :format
  json.type 'ResponseDomainDatetime'
end

json.array!(@collection) do |response_domain_numeric|
  json.extract! response_domain_numeric, :id, :label, :min, :max
  json.subtype response_domain_numeric.numeric_type
  json.type 'ResponseDomainNumeric'
end

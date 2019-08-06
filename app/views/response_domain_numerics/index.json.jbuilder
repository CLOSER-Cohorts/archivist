json.array!(@collection) do |response_domain_numeric|
  json.extract! response_domain_numeric, :id, :label
  json.min (response_domain_numeric.numeric_type == 'Integer') ? response_domain_numeric.min.to_i : response_domain_numeric.min.to_f
  json.max (response_domain_numeric.numeric_type == 'Integer') ? response_domain_numeric.max.to_i : response_domain_numeric.max.to_f
  json.subtype response_domain_numeric.numeric_type
  json.type 'ResponseDomainNumeric'
end

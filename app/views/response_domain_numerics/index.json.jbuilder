# frozen_string_literal: true

json.array!(@collection) do |response_domain_numeric|
  json.extract! response_domain_numeric, :id, :label, :min, :max
  json.subtype response_domain_numeric.numeric_type
  json.type 'ResponseDomainNumeric'
  json.used_by response_domain_numeric.questions do |obj|
    json.type obj.class.name
    json.id obj.id
    json.label obj.label
  end
end

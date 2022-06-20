# frozen_string_literal: true

json.array!(@collection) do |response_domain_datetime|
  json.extract! response_domain_datetime, :id, :label, :format
  json.subtype response_domain_datetime.datetime_type
  json.type 'ResponseDomainDatetime'
  json.used_by response_domain_datetime.questions do |obj|
    json.type obj.class.name
    json.id obj.id
    json.label obj.label
  end
end

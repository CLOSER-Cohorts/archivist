# frozen_string_literal: true

json.array!(@collection) do |response_domain_text|
  json.extract! response_domain_text, :id, :label, :maxlen
  json.type 'ResponseDomainText'
  json.used_by response_domain_text.questions do |obj|
    json.type obj.class.name
    json.id obj.id
    json.label obj.label
  end
end

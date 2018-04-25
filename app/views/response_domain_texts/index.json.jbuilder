json.array!(@collection) do |response_domain_text|
  json.extract! response_domain_text, :id, :label, :maxlen
  json.type 'ResponseDomainText'
end

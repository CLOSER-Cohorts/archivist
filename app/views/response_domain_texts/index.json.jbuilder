json.array!(@response_domain_texts) do |response_domain_text|
  json.extract! response_domain_text, :id, :label, :maxlen
  json.url response_domain_text_url(response_domain_text, format: :json)
end

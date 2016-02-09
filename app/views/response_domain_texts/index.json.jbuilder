json.array!(@response_domain_texts) do |response_domain_text|
  json.extract! response_domain_text, :id, :label, :maxlen
end

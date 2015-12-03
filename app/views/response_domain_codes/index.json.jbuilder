json.array!(@response_domain_codes) do |response_domain_code|
  json.extract! response_domain_code, :id, :code_list_id
  json.url response_domain_code_url(response_domain_code, format: :json)
end

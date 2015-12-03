json.array!(@response_domain_datetimes) do |response_domain_datetime|
  json.extract! response_domain_datetime, :id, :datetime_type, :label, :format
  json.url response_domain_datetime_url(response_domain_datetime, format: :json)
end

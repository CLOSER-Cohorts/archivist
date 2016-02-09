json.array!(@response_domain_datetimes) do |response_domain_datetime|
  json.extract! response_domain_datetime, :id, :datetime_type, :label, :format
end

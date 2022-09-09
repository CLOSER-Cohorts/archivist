# frozen_string_literal: true

unless rd.nil?
  json.id rd.id
  json.type rd.class.name
  json.label rd.label
  if rd.class == ResponseDomainCode
    json.min_responses rd.min_responses
    json.max_responses rd.max_responses
    json.codes rd.codes, :label, :value, :order
  elsif rd.class.name == 'ResponseDomainText'
    json.maxlen rd.maxlen
  else
    json.subtype rd.subtype
    json.params rd.params
  end
end
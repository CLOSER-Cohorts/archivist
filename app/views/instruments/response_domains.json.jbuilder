json.array! @instrument.response_domains do |rd|
  json.id rd.id
  json.type rd.class.name
  json.label rd.label
end
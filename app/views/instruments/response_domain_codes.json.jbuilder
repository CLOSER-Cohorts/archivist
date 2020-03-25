json.array! @object.response_domain_codes.group_by(&:code_list_id) do | code_list_id, rds|
  rd = rds.first
  json.id rd.id
  json.type rd.class.name
  json.label rd.label
end

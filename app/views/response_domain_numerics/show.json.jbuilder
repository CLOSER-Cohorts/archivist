json.extract! @object, :id, :label, :min, :max
json.subtype @object.numeric_type
json.type 'ResponseDomainNumeric'

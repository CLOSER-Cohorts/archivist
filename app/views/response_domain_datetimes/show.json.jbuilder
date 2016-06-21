json.extract! @object, :id, :label, :format
json.subtype @object.datetime_type
json.type 'ResponseDomainDatetime'

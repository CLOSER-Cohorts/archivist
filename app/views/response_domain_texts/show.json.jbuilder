# frozen_string_literal: true

json.extract! @object, :id, :label, :maxlen, :created_at, :updated_at
json.type 'ResponseDomainText'

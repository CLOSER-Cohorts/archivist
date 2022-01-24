# frozen_string_literal: true

json.extract! @object, :id, :name, :study, :filename
json.variables @object.variables.count

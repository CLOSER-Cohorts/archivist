# frozen_string_literal: true

json.extract! @object, :id, :name, :study, :filename, :doi
json.variables @object.variables.count

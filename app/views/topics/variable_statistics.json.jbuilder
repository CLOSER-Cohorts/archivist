# frozen_string_literal: true

json.array! @object.variable_statistics do |stat|
  json.study stat['study']
  json.count stat['count']
end
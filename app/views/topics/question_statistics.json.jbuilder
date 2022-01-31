# frozen_string_literal: true

json.array! @object.question_statistics do |stat|
  json.study stat['study']
  json.count stat['count']
end
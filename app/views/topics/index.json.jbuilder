# frozen_string_literal: true

json.array!(@collection) do |topic|
  json.extract! topic, :id, :name
  unless topic.level.nil?
    json.level topic.level
  end
end

# frozen_string_literal: true

json.array!(@collection) do |instruction|
  json.extract! instruction, :id, :text
end

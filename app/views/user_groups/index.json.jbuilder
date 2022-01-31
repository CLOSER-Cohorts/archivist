# frozen_string_literal: true

json.array!(@collection) do |group|
  json.extract! group, :id, :label, :group_type
  if group.study.is_a? Array
    json.study group.study do |study|
      json.label study
    end
  else
    json.study group.study
  end
end

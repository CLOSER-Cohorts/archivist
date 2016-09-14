json.array!(@collection) do |cc_condition|
  json.extract! cc_condition, :id, :literal, :logic, :position
  json.label cc_condition.label
  json.children cc_condition.construct_children 0
  json.fchildren cc_condition.construct_children 1
  json.parent cc_condition.parent_id
  json.topic cc_condition.topic
end

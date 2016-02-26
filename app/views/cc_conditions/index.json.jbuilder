json.array!(@collection) do |cc_condition|
  json.extract! cc_condition, :id, :literal, :logic, :position
  json.label cc_condition.label
  json.children cc_condition.children do |child|
    json.id child.construct.id
    json.type child.construct.class.name
  end
  json.parent cc_condition.parent.id
end

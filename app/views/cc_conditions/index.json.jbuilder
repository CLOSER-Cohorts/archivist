json.array!(@collection) do |cc_condition|
  json.extract! cc_condition, :id, :literal, :logic, :position
  json.label cc_condition.label
  json.children cc_condition.children.where(branch: 0) do |child|
    json.id child.construct.id
    json.type child.construct.class.name
  end
  json.fchildren cc_condition.children.where(branch: 1) do |child|
    json.id child.construct.id
    json.type child.construct.class.name
  end
  json.parent cc_condition.parent.id
end

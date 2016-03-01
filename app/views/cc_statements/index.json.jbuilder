json.array!(@collection) do |cc_statement|
  json.extract! cc_statement, :id, :literal, :position
  json.label cc_statement.label
  json.parent cc_statement.parent.id
end

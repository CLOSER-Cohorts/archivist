json.array!(@cc_statements) do |cc_statement|
  json.extract! cc_statement, :id, :literal
  json.label cc_statement.label
end

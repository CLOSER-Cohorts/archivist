json.array!(@cc_statements) do |cc_statement|
  json.extract! cc_statement, :id, :literal
  json.label cc_statement.label
  json.url cc_statement_url(cc_statement, format: :json)
end

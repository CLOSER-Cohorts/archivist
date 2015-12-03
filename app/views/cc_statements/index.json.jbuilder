json.array!(@cc_statements) do |cc_statement|
  json.extract! cc_statement, :id, :literal
  json.url cc_statement_url(cc_statement, format: :json)
end

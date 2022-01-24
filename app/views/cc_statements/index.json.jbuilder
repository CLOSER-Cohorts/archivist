# frozen_string_literal: true

json.array!(@collection) do |cc_statement|
  json.extract! cc_statement, :id, :literal, :position, :branch
  json.label cc_statement.label
  json.parent_id cc_statement.parent_id
  json.parent_type cc_statement.parent_type
end

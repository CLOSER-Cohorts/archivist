# frozen_string_literal: true

json.extract! @object, :id, :agency, :version, :prefix, :label, :study, :signed_off, :slug
json.ccs @object.ccs.count
json.export_url @object.export_url
json.export_time @object.export_time
json.last_edited_time @object.last_edited_time
if @object.respond_to?(:exports)
  json.exports do
    json.array! @object.exports, :id, :created_at
  end
end
json.extract! @object, :id, :agency, :version, :prefix, :label, :study
json.ccs @object.ccs.count
json.export_url @object.export_url
json.export_time @object.export_time
json.last_edited_time @object.last_edited_time
json.extract! @object, :id, :agency, :version, :prefix, :label, :study
json.ccs @object.ccs.count
json.export_url @object.export_url
json.array!(@collection) do |instrument|
  json.extract! instrument, :id, :agency, :version, :prefix, :label, :study
  json.ccs instrument.cc_count
  json.export_url instrument.export_url
end

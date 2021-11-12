json.array!(@collection) do |instrument|
  json.extract! instrument, :id, :agency, :version, :prefix, :label, :study, :signed_off
  json.ccs instrument.cc_count
  json.qvs @qv_counts[instrument.id]
  json.export_url instrument.export_url
  json.export_time instrument.export_time
  json.last_edited_time instrument.last_edited_time
  json.datasets instrument.datasets do |dataset|
    json.id dataset.id
    json.name dataset.name
    json.instance_name dataset.instance_name
  end
end

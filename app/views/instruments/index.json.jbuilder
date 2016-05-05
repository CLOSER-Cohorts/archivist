json.cache_collection! @collection, expires_in: 30.days, key: proc {|instrument| instrument.updated_at} do |instrument|
  json.extract! instrument, :id, :agency, :version, :prefix, :label, :study
  json.ccs instrument.cc_count
end

json.array!(@instruments) do |instrument|
  json.extract! instrument, :id, :agency, :version, :prefix, :label, :study
  json.url instrument_url(instrument, format: :json)
end

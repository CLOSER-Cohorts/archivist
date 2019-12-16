json.extract! import, :id, :import_type, :dataset_id, :state
json.created_at import.created_at.strftime('%a, %e %b %Y %H:%M:%S %z')
json.filename import.filename

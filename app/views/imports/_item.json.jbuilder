# frozen_string_literal: true

json.extract! import, :id, :import_type, :dataset_id, :state
json.created_at import.created_at.strftime('%a, %e %b %Y %H:%M:%S %z')
json.filename @documents.find{|doc| doc.id == import.document_id}.try(:filename)

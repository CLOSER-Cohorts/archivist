# frozen_string_literal: true

json.extract! export, :id, :export_type, :dataset_id, :state
json.instrument_name export.instrument.try(:name)
json.instrument_prefix export.instrument.try(:prefix)
json.dataset_name export.dataset.try(:name)
json.created_at export.created_at.strftime('%a, %e %b %Y %H:%M:%S %z')
json.filename @documents.find{|doc| doc.id == export.document_id}.try(:filename)

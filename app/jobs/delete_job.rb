# frozen_string_literal: true

module DeleteJob; end

class DeleteJob::Instrument
  include Sidekiq::Worker

  sidekiq_options queue: 'in_and_out'

  def perform (instrument_id)
    begin
      instrument = ::Instrument.find instrument_id
      instrument.destroy
      ::Instrument.last.touch(:updated_at)
    rescue => e
      Rails.logger.fatal e
    end
  end
end

class DeleteJob::Dataset
  include Sidekiq::Worker

  sidekiq_options queue: 'in_and_out'

  def perform (dataset_id)
    begin
      dataset = Dataset.find dataset_id
      dataset.destroy
    rescue => e
      Rails.logger.fatal e
    end
  end
end

class DeleteJob::DocumentBatch
  include Sidekiq::Worker

  sidekiq_options queue: 'in_and_out'

  # Process documents in batches - much more efficient than one job per document
  def perform(batch_size: 100)
    deleted_count = Document.cleanup_old_documents(dry_run: false)
    Rails.logger.info "Document batch cleanup: deleted #{deleted_count} documents"
    deleted_count
  end
end

class DeleteJob::Document
  include Sidekiq::Worker

  sidekiq_options queue: 'in_and_out'

  def perform(document_id)
    begin
      # OPTIMIZATION: Don't load file_contents blob (saves ~919KB per document)
      # We only need the ID and relationships for deletion logic
      document = Document.select(Document.column_names - ['file_contents']).find(document_id)

      # Pre-check: Is this document referenced by ANY import or export?
      # This is much faster than calling preservation_reasons
      has_import = Import.where(document_id: document_id).exists?
      has_export = Export.where(document_id: document_id).exists?

      if !has_import && !has_export
        # Completely orphaned document - safe to delete
        document.destroy
        Rails.logger.info "Document cleanup job: deleted orphaned document #{document_id}"
      else
        # Document is referenced - use the more expensive safe_to_delete? check
        if document.safe_to_delete?
          # First nullify any remaining foreign key references
          Import.where(document_id: document.id).update_all(document_id: nil)
          Export.where(document_id: document.id).update_all(document_id: nil)

          # Then destroy the document
          document.destroy
          Rails.logger.info "Document cleanup job: deleted document #{document_id}"
        else
          reasons = document.preservation_reasons
          Rails.logger.info "Document cleanup job: skipped document #{document_id} - preserved because: #{reasons.join(', ')}"
        end
      end
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn "Document cleanup job: document #{document_id} not found, may have been already deleted"
    rescue => e
      Rails.logger.error "Document cleanup job failed for document #{document_id}: #{e.message}"
      raise e
    end
  end
end

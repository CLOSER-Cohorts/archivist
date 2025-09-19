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

class DeleteJob::Document
  include Sidekiq::Worker

  sidekiq_options queue: 'in_and_out'

  def perform(document_id)
    begin
      document = Document.find(document_id)
      
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
    rescue ActiveRecord::RecordNotFound
      Rails.logger.warn "Document cleanup job: document #{document_id} not found, may have been already deleted"
    rescue => e
      Rails.logger.error "Document cleanup job failed for document #{document_id}: #{e.message}"
      raise e
    end
  end
end

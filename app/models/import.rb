# frozen_string_literal: true

class Import < ApplicationRecord
  belongs_to :document
  belongs_to :dataset
  belongs_to :instrument

  delegate :filename, to: :document, allow_nil: true

  # Cleanup old documents when import completes successfully
  after_update :cleanup_old_documents, if: :saved_change_to_state?

  def parsed_log
    JSON.parse(log,symbolize_names: true) rescue []
  end

  private

  def cleanup_old_documents
    # Only cleanup when state changes to completed (not pending)
    return if state == 'pending'
    
    Document.cleanup_for_type(
      type: import_type,
      instrument_id: instrument_id,
      dataset_id: dataset_id
    )
  end
end

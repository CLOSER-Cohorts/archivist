# frozen_string_literal: true

# Stores documents into the database
#
# Instead of a shared file store between web server nodes, Archivist
# makes use of the database as files are not accessed frequently
# enough to cause performance issues.
#
# === Properties
# * filename
# * content_type
# * file_contents
# * md5_hash
class Document < ApplicationRecord
  # Each Document can belong to any other database model
  belongs_to :item, polymorphic: true

  # Creates a new Document
  #
  # @param [Hash] params Parameters for creating a new Document
  # @return [Document]
  def initialize(params={})
    file = params.try(:delete, :file)
    super
    if file.is_a? ActionDispatch::Http::UploadedFile
      self.filename = sanitize_filename file.original_filename
      self.content_type = file.content_type
      self.file_contents = file.read
      self.md5_hash = Digest::MD5.hexdigest self.file_contents
    elsif file.is_a? File
      self.filename = sanitize_filename file.path
      self.file_contents = file.read
      self.md5_hash = Digest::MD5.hexdigest self.file_contents
    elsif file.is_a? String # i.e. comes from a base encoding
      self.filename = Digest::MD5.hexdigest(Time.now.to_s) + '.txt'
      self.file_contents = file
      self.md5_hash = Digest::MD5.hexdigest file
    end
  end

  # Either save the new Document or if the md5_hash has already been used
  # return the Document from the database
  #
  # @return [Document]
  def save_or_get
    begin
      self.save!
    rescue ActiveRecord::RecordNotUnique, PG::UniqueViolation
      self.id = Document.find_by_md5_hash(self.md5_hash).id
    end
  end

  # Returns documents that are completely orphaned (not referenced by any import/export)
  # This is the safest cleanup - only removes documents with no references at all
  #
  # @return [ActiveRecord::Relation] Documents that are completely orphaned
  def self.orphaned_documents
    # Get ALL documents referenced by imports/exports
    referenced_doc_ids = (Import.pluck(:document_id) + Export.pluck(:document_id)).compact.uniq
    
    # Return documents not referenced by any import or export
    where.not(id: referenced_doc_ids)
  end

  # Returns documents that are safe to delete based on import/export retention policy
  # Keeps only the latest document for each import/export type per instrument/dataset
  # Also preserves any documents linked to pending imports/exports
  #
  # @return [ActiveRecord::Relation] Documents that can be safely deleted
  def self.safe_to_delete
    # Get latest import document per type per instrument/dataset using Ruby grouping
    latest_import_docs = Import.includes(:document)
      .order(created_at: :desc)
      .group_by { |i| [i.import_type, i.instrument_id, i.dataset_id] }
      .map { |_key, imports| imports.first.document_id }
      .compact

    # Get latest export document per type per instrument/dataset using Ruby grouping
    latest_export_docs = Export.includes(:document)
      .order(created_at: :desc)
      .group_by { |e| [e.export_type, e.instrument_id, e.dataset_id] }
      .map { |_key, exports| exports.first.document_id }
      .compact

    # Get documents linked to any pending imports/exports (these must be preserved)
    pending_import_docs = Import.where(state: 'pending').pluck(:document_id).compact
    pending_export_docs = Export.where(state: 'pending').pluck(:document_id).compact

    # All documents to preserve
    preserve_doc_ids = (latest_import_docs + latest_export_docs + pending_import_docs + pending_export_docs).uniq

    # Return documents not in the preserve list
    where.not(id: preserve_doc_ids)
  end

  # Returns detailed information about imports and exports for analysis
  #
  # @return [Hash] Summary of import/export states and document usage
  def self.import_export_summary
    {
      imports: {
        total: Import.count,
        by_state: Import.group(:state).count,
        by_type: Import.group(:import_type).count,
        with_documents: Import.where.not(document_id: nil).count,
        pending_count: Import.where(state: 'pending').count
      },
      exports: {
        total: Export.count,
        by_state: Export.group(:state).count,
        by_type: Export.group(:export_type).count,
        with_documents: Export.where.not(document_id: nil).count,
        pending_count: Export.where(state: 'pending').count
      },
      documents: {
        total: Document.count,
        referenced_by_imports: Document.joins('INNER JOIN imports ON imports.document_id = documents.id').distinct.count,
        referenced_by_exports: Document.joins('INNER JOIN exports ON exports.document_id = documents.id').distinct.count,
        safe_to_delete: safe_to_delete_count,
        preserved_for_pending: (Import.where(state: 'pending').pluck(:document_id) + Export.where(state: 'pending').pluck(:document_id)).compact.uniq.count
      }
    }
  end

  # Returns breakdown of which documents are preserved and why
  #
  # @return [Hash] Detailed breakdown of document preservation reasons
  def self.preservation_breakdown
    latest_import_docs = Import.includes(:document)
      .order(created_at: :desc)
      .group_by { |i| [i.import_type, i.instrument_id || 0, i.dataset_id || 0] }
      .map { |_key, imports| imports.first.document_id }
      .compact

    latest_export_docs = Export.includes(:document)
      .order(created_at: :desc)
      .group_by { |e| [e.export_type, e.instrument_id || 0, e.dataset_id || 0] }
      .map { |_key, exports| exports.first.document_id }
      .compact

    pending_import_docs = Import.where(state: 'pending').pluck(:document_id).compact
    pending_export_docs = Export.where(state: 'pending').pluck(:document_id).compact

    {
      latest_imports: latest_import_docs.count,
      latest_exports: latest_export_docs.count,
      pending_imports: pending_import_docs.count,
      pending_exports: pending_export_docs.count,
      total_preserved: (latest_import_docs + latest_export_docs + pending_import_docs + pending_export_docs).uniq.count,
      safe_to_delete: safe_to_delete_count
    }
  end

  # Returns count of documents that would be deleted
  #
  # @return [Integer] Number of documents that can be safely deleted
  def self.safe_to_delete_count
    safe_to_delete.count
  end

  # Performs the actual cleanup of old documents
  # First nullifies foreign key references, then deletes documents
  # 
  # @param [Boolean] dry_run If true, only returns count without deleting
  # @return [Integer] Number of documents deleted (or would be deleted if dry_run)
  def self.cleanup_old_documents(dry_run: true)
    documents_to_delete = safe_to_delete
    document_ids_to_delete = documents_to_delete.pluck(:id)
    count = document_ids_to_delete.count
    
    unless dry_run
      # First, nullify foreign key references to these documents
      Import.where(document_id: document_ids_to_delete).update_all(document_id: nil)
      Export.where(document_id: document_ids_to_delete).update_all(document_id: nil)
      
      # Then delete the documents
      documents_to_delete.destroy_all
      
      Rails.logger.info "Document cleanup: deleted #{count} old documents"
    end
    
    count
  end

  # Cleanup documents for a specific import/export type and item
  # Called when new imports/exports are created
  #
  # @param [String] type The import_type or export_type 
  # @param [Integer] instrument_id The instrument ID (can be nil)
  # @param [Integer] dataset_id The dataset ID (can be nil)
  def self.cleanup_for_type(type:, instrument_id: nil, dataset_id: nil)
    if type.start_with?('ImportJob::')
      # Find old imports of this type for this item
      old_imports = Import.where(
        import_type: type,
        instrument_id: instrument_id,
        dataset_id: dataset_id
      ).where.not(state: 'pending')
       .order(created_at: :desc)
       .offset(1) # Keep the latest one
      
      old_document_ids = old_imports.pluck(:document_id).compact
    elsif type.start_with?('ExportJob::')
      # Find old exports of this type for this item  
      old_exports = Export.where(
        export_type: type,
        instrument_id: instrument_id,
        dataset_id: dataset_id
      ).where.not(state: 'pending')
       .order(created_at: :desc)
       .offset(1) # Keep the latest one
      
      old_document_ids = old_exports.pluck(:document_id).compact
    else
      return 0
    end
    
    if old_document_ids.any?
      # Nullify references and delete old documents
      Import.where(document_id: old_document_ids).update_all(document_id: nil)
      Export.where(document_id: old_document_ids).update_all(document_id: nil)
      
      deleted_count = Document.where(id: old_document_ids).destroy_all.count
      Rails.logger.info "Document cleanup for #{type}: deleted #{deleted_count} old documents"
      
      deleted_count
    else
      0
    end
  end

  # Checks if this specific document is safe to delete using the same business logic
  # as the class methods
  #
  # @return [Boolean] true if this document can be safely deleted
  def safe_to_delete?
    # A document is safe to delete if it has NO preservation reasons
    preservation_reasons.empty?
  end

  # Returns why this document is being preserved (if it is)
  #
  # @return [Array<String>] Reasons why this document is preserved, empty if safe to delete
  def preservation_reasons
    reasons = []
    
    # Check if it's the latest import for any type/instrument/dataset combination
    latest_import_docs = Import.includes(:document)
      .order(created_at: :desc)
      .group_by { |i| [i.import_type, i.instrument_id, i.dataset_id] }
      .map { |_key, imports| imports.first.document_id }
      .compact
    
    if latest_import_docs.include?(self.id)
      reasons << "Latest import document for a type/instrument/dataset combination"
    end
    
    # Check if it's the latest export for any type/instrument/dataset combination  
    latest_export_docs = Export.includes(:document)
      .order(created_at: :desc)
      .group_by { |e| [e.export_type, e.instrument_id, e.dataset_id] }
      .map { |_key, exports| exports.first.document_id }
      .compact
      
    if latest_export_docs.include?(self.id)
      reasons << "Latest export document for a type/instrument/dataset combination"
    end
    
    # Check if linked to pending imports
    if Import.where(state: 'pending', document_id: self.id).exists?
      reasons << "Linked to pending import(s)"
    end
    
    # Check if linked to pending exports
    if Export.where(state: 'pending', document_id: self.id).exists?
      reasons << "Linked to pending export(s)"
    end
    
    reasons
  end

  private # Private methods

  # Prepare the filename for saving
  def sanitize_filename(filename)
    File.basename(filename)
  end
end

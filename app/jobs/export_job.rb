# frozen_string_literal: true

module ExportJob; end

class ExportJob::Base
  include Sidekiq::Worker
  include Exporters::Loggable

  sidekiq_options queue: 'in_and_out'

  def perform(id, options = {})
    export_id = options["export_id"]
    setup_export(export_id)

    begin
      set_export_to_running
      process_export(id)
      log(:outcome, "#{self.class.name.demodulize} completed successfully")
    rescue StandardError => e
      handle_failure(e)
    ensure
      write_to_log
      set_export_to_finished
    end
  end

  private

  def setup_export(export_id)
    @export = Export.find_by(id: export_id)
    return if export_id.nil? || @export.present?

    Rails.logger.error "Export ID #{export_id} not found."
    raise ActiveRecord::RecordNotFound, "Export with ID #{export_id} not found"
  end

  def handle_failure(exception)
    @errors = true
    log(:outcome, "Job failed: #{exception.message}")
    log(:backtrace, exception.backtrace[0..10])
    Rails.logger.fatal(exception)
  end

  def process_export(_id)
    raise NotImplementedError, "Subclasses must implement `process_export`"
  end

  def save_document(instrument_or_dataset:, filename:, document_type:, file_contents:)
    document = Document.new(
      filename: filename,
      document_type: document_type,
      content_type: 'text/xml',
      file_contents: file_contents,
      md5_hash: Digest::MD5.hexdigest(file_contents)
    )
    document.save!
    @export.document = document if @export.present?
    instrument_or_dataset.add_export_document(document) if instrument_or_dataset.respond_to?(:add_export_document)
  end
end

class ExportJob::Instrument < ExportJob::Base
  private

  def process_export(id)
    instrument = ::Instrument.find(id)
    exporter = Exporters::XML::DDI::Instrument.new

    build_export(exporter, instrument)

    save_document(
      instrument_or_dataset: instrument,
      filename: "#{instrument.prefix}.xml",
      document_type: 'instrument_export',
      file_contents: exporter.doc.to_xml(&:no_empty_tags)
    )
  end
end

class ExportJob::InstrumentComplete < ExportJob::Base
  private

  def process_export(id)
    instrument = ::Instrument.find(id)
    exporter = Exporters::XML::DDI::InstrumentComplete.new

    build_export(exporter, instrument)

    save_document(
      instrument_or_dataset: instrument,
      filename: "#{instrument.prefix}_complete.xml",
      document_type: 'instrument_export_complete',
      file_contents: exporter.doc.to_xml(&:no_empty_tags)
    )
  end
end

class ExportJob::Dataset < ExportJob::Base
  private

  def process_export(id)
    dataset = Dataset.find(id)
    exporter = Exporters::XML::DDI::Dataset.new

    exporter.run(dataset)

    save_document(
      instrument_or_dataset: dataset,
      filename: dataset.filename,
      document_type: 'dataset_export',
      file_contents: exporter.doc.to_xml(&:no_empty_tags)
    )
  end
end

module Exporters::BaseSteps
  def build_export(exporter, exportable)
    exporter.add_root_attributes
    exporter.export_instrument(exportable)

    # Dynamically call all export building steps
    %i[rp iis cs cls qis qgs is ccs].each do |step|
      exporter.public_send("build_#{step}")
    end
  end
end

ExportJob::Base.include Exporters::BaseSteps
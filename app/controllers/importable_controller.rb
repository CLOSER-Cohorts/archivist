# frozen_string_literal: true

class ImportableController < BasicController
  class << self
    attr_accessor :model_importer_class
  end

  def import
    files = params[:files].nil? ? [] : params[:files]
    options = {}
    options[:prefix] = params[:instrument_prefix] if params.has_key? :instrument_prefix
    options[:agency] = params[:instrument_agency] if params.has_key? :instrument_agency
    options[:study] = params[:instrument_study] if params.has_key? :instrument_study
    head :ok, format: :json if files.empty?
    begin
      files.each do |file|
        doc = Document.new file: file
        doc.save_or_get
        import = Import.create(document_id: doc.id, import_type: self.class.model_importer_class, state: :pending)
        options[:import_id] = import.id
        self.class.model_importer_class.perform_async(doc.id, options)
      end
      head :ok, format: :json
    rescue  => e
      render json: {message: e}, status: :bad_request
    end
  end
end

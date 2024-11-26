# frozen_string_literal: true

class ExportsController < ApplicationController
  before_action :set_documents

  def index
    @exports = Export.where(export_type: ['ExportJob::Instrument','ExportJob::InstrumentComplete', 'ExportJob::Dataset']).order('exports.created_at DESC')
  end

  def show
    @export = Export.find(params[:id])
  end

  def document
    @export = Export.find(params[:id])
    @document = @export.document

    file_name = @document.filename
    file_contents = @document.file_contents
  
    send_data file_contents, filename: file_name, type: "text/xml", disposition: "attachment"
  end

  private

  def set_documents
    @documents = Document.all.select(:id, :filename)
  end
end

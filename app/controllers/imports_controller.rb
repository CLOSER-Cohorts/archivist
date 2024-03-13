# frozen_string_literal: true

class ImportsController < ApplicationController
  before_action :set_documents

  def index
    @imports = Import.where(import_type: 'ImportJob::Instrument').order('imports.created_at DESC')
  end

  def show
    @import = Import.find(params[:id])
  end

  def document
    @import = Import.find(params[:id])
    @document = @import.document

    file_name = @document.filename
    file_contents = @document.file_contents
  
    send_data file_contents, filename: file_name, type: "text/xml", disposition: "attachment"
  end

  private

  def set_documents
    @documents = Document.all.select(:id, :filename)
  end
end

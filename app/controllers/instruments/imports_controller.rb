# frozen_string_literal: true

class Instruments::ImportsController < ApplicationController
  def index
    instrument = Instrument.friendly.find(params[:instrument_id])
    @imports = instrument.imports.order(created_at: 'DESC')
  end

  def show
    instrument = Instrument.friendly.find(params[:instrument_id])
    @import = instrument.imports.find(params[:id])
  end

  def document
    instrument = Instrument.friendly.find(params[:instrument_id])
    @import = instrument.imports.find(params[:id])    
    @document = @import.document

    file_name = @document.filename
    file_contents = @document.file_contents
  
    send_data file_contents, filename: file_name, type: "text/plain", disposition: "attachment"
  end
end

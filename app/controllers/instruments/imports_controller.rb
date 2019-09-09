class Instruments::ImportsController < ApplicationController
  def index
    instrument = Instrument.friendly.find(params[:instrument_id])
    @imports = instrument.imports.order(created_at: 'DESC')
  end

  def show
    instrument = Instrument.friendly.find(params[:instrument_id])
    @import = instrument.imports.find(params[:id])
  end
end

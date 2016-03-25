class InstructionsController < ApplicationController
  include BaseInstrumentController

  add_basic_actions require: ':instruction',
                    params: '[:text]',
                    collection: 'Instrument.find(params[:instrument_id]).instructions'

end
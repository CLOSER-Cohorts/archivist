class CcSequencesController < ApplicationController
  include BaseInstrumentController

  add_basic_actions require: ':cc_sequence',
                    params: '[:literal]',
                    collection: 'Instrument.find(params[:instrument_id]).cc_sequences'

end
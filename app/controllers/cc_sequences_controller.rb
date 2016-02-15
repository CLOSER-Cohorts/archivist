class CcSequencesController < ApplicationController
  include BaseController

  add_basic_actions require: ':cc_sequence',
                    params: '[:literal]',
                    collection: 'Instrument.find(params[:instrument_id]).cc_sequences'

end
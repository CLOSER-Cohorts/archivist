class CodeListsController < ApplicationController
  include BaseInstrumentController

  add_basic_actions require: ':code_list',
                    params: '[:label, :codes]',
                    collection: 'Instrument.find(params[:instrument_id]).code_lists'

end
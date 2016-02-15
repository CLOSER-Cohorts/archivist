class CcLoopsController < ApplicationController
  include BaseController

  add_basic_actions require: ':cc_loop',
                    params: '[:loop_var, :start_val, :end_val, :loop_while]',
                    collection: 'Instrument.find(params[:instrument_id]).cc_loops'

end
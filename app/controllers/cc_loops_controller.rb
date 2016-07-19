class CcLoopsController < ApplicationController
  include Construct::Controller

  add_basic_actions require: ':cc_loop',
                    params: '[:label, :loop_var, :start_val, :end_val, :loop_while, :parent, :position, :branch]',
                    collection: 'Instrument.find(params[:instrument_id]).cc_loops'

end
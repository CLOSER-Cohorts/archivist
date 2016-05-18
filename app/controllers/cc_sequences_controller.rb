class CcSequencesController < ApplicationController
  include Construct::Controller

  add_basic_actions require: ':cc_sequence',
                    params: '[:literal, :parent, :position, :branch]',
                    collection: 'Instrument.find(params[:instrument_id]).cc_sequences'

end
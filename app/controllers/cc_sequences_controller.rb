class CcSequencesController < ApplicationController
  include Construct::Controller

  add_basic_actions require: ':cc_sequence',
                    params: '[:label, :literal, :parent, :position, :branch]',
                    collection: 'Instrument.find(Prefix[params[:instrument_id]]).cc_sequences'

end
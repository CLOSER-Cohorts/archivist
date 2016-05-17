class CcStatementsController < ApplicationController
  include Construct::Controller

  add_basic_actions require: ':cc_statement',
                    params: '[:literal, :parent, :position, :branch]',
                    collection: 'Instrument.find(params[:instrument_id]).cc_statements'

end
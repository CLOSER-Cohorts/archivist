class CcStatementsController < ApplicationController
  include BaseController

  add_basic_actions require: ':cc_statement',
                    params: '[:literal]',
                    collection: 'Instrument.find(params[:instrument_id]).cc_statements'

end
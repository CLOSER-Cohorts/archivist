class CcConditionsController < ApplicationController
  include BaseController

  add_basic_actions require: ':cc_condition',
                    params: '[:literal, :logic]',
                    collection: 'Instrument.find(params[:instrument_id]).cc_conditions'

end
class CcConditionsController < ApplicationController
  include BaseInstrumentController

  add_basic_actions require: ':cc_condition',
                    params: '[:literal, :logic]',
                    collection: 'Instrument.find(params[:instrument_id]).cc_conditions'

end
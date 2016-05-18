class CcConditionsController < ApplicationController
  include Construct::Controller

  add_basic_actions require: ':cc_condition',
                    params: '[:literal, :logic, :parent, :position, :branch]',
                    collection: 'Instrument.find(params[:instrument_id]).cc_conditions'

end
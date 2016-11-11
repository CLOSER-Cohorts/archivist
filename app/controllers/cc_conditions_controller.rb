class CcConditionsController < ApplicationController
  include Construct::Controller

  add_basic_actions require: ':cc_condition',
                    params: '[:label, :literal, :logic, :parent, :position, :branch]',
                    collection: 'Instrument.find(Prefix[params[:instrument_id]]).cc_conditions'

end
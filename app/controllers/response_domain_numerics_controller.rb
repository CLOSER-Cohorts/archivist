class ResponseDomainNumericsController < ApplicationController
  include BaseInstrumentController

  add_basic_actions require: ':response_domain_numeric',
                    params: '[:numeric_type, :label, :min, :max]',
                    collection: 'Instrument.find(params[:instrument_id]).response_domain_numerics'

end
class ResponseDomainDatetimesController < ApplicationController
  include BaseController

  add_basic_actions require: ':response_domain_datetime',
                    params: '[:datetime_type, :label, :format]',
                    collection: 'Instrument.find(params[:instrument_id]).response_domain_datetimes'

end
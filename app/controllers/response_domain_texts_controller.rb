class ResponseDomainTextsController < ApplicationController
  include BaseController

  add_basic_actions require: ':response_domain_text',
                    params: '[:label, :maxlen]',
                    collection: 'Instrument.find(params[:instrument_id]).response_domain_texts'

end
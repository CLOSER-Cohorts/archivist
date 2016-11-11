class ResponseDomainNumericsController < ApplicationController
  include BaseInstrumentController

  add_basic_actions require: ':response_domain_numeric',
                    params: '[:numeric_type, :label, :min, :max]',
                    collection: 'Instrument.find(Prefix[params[:instrument_id]]).response_domain_numerics'

  before_action :subtype_shim, only: [:create, :update]

  private
  def subtype_shim
    params[:response_domain_numeric][:numeric_type] = params[:subtype]
  end

end
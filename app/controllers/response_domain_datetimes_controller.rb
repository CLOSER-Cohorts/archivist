class ResponseDomainDatetimesController < ApplicationController
  include BaseInstrumentController

  add_basic_actions require: ':response_domain_datetime',
                    params: '[:datetime_type, :label, :format]',
                    collection: 'Instrument.find(Prefix[params[:instrument_id]]).response_domain_datetimes'

  before_action :subtype_shim, only: [:create, :update]

  private
  def subtype_shim
    params[:response_domain_datetime][:datetime_type] = params[:subtype]
  end

end
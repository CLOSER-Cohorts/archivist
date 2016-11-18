class ResponseDomainDatetimesController < BasicInstrumentController
  include RdSubtypeShim
  only_set_object
  permit_subtype :datetime_type

  @model_class = ResponseDomainDatetime
  @params_list = [:datetime_type, :label, :format]
end
class ResponseDomainNumericsController < BasicInstrumentController
  include RdSubtypeShim
  only_set_object
  permit_subtype :numeric_type

  @model_class = ResponseDomainNumeric
  @params_list = [:numeric_type, :label, :min, :max]
end
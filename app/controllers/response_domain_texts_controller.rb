class ResponseDomainTextsController < BasicInstrumentController
  only_set_object

  @model_class = ResponseDomainText
  @params_list = [:label, :maxlen]
end
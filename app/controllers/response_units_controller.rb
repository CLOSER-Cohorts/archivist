class ResponseUnitsController < BasicInstrumentController
  only_set_object

  @model_class = ResponseUnit
  @params_list = [:label]
end
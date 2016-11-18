class InstructionsController < BasicInstrumentController
  only_set_object

  @model_class = Instruction
  @params_list = [:text]
end
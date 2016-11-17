class CcSequencesController < ConstructController
  only_set_object

  @model_class = CcSequence
  @params_list = [:label, :literal, :parent, :position, :branch]
end
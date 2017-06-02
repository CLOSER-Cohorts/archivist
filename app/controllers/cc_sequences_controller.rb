class CcSequencesController < ConstructController
  include Linkable::Controller

  only_set_object { %i{set_topic} }

  @model_class = CcSequence
  @params_list = [:label, :literal, :parent, :position, :branch]
end
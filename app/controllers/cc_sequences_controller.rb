class CcSequencesController < ConstructController
  include Linkable::Controller

  only_set_object { %i{set_topic} }

  @model_class = CcSequence
  @params_list = [:label, :literal, :parent_id, :parent_type, :position, :branch]
end
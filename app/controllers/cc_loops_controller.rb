class CcLoopsController < ConstructController
  include Linkable::Controller

  only_set_object { %i{set_topic} }

  @model_class = CcLoop
  @params_list = [:loop_var, :start_val, :end_val, :loop_while]
end
class CcLoopsController < ConstructController
  include Linkable::Controller

  only_set_object { %i{set_topic} }

  @model_class = CcLoop
  @params_list = [:label, :loop_var, :start_val, :end_val, :loop_while, :parent, :position, :branch]
end
class CcLoopsController < ConstructController
  only_set_object

  @model_class = CcLoop
  @params_list = [:label, :loop_var, :start_val, :end_val, :loop_while, :parent, :position, :branch]
end
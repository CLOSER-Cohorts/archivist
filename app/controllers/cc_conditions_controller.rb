class CcConditionsController < ConstructController
  only_set_object

  @model_class = CcCondition
  @params_list = [:label, :literal, :logic, :parent, :position, :branch]
end
class CcConditionsController < ConstructController
  include Linkable::Controller

  only_set_object { %i{set_topic} }

  @model_class = CcCondition
  @params_list = [:literal, :logic]
end
class CcStatementsController < ConstructController
  only_set_object

  @model_class = CcStatement
  @params_list = [:label, :literal, :parent_id, :parent_type, :position, :branch]
end
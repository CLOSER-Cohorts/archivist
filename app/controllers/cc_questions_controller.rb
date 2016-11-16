class CcQuestionsController < ConstructController
  only_set_object

  @model_class = CcQuestion
  @params_list = [:label, :question_id, :question_type, :response_unit_id, :parent, :position, :branch]
end
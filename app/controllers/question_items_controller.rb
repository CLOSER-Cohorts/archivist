class QuestionItemsController < QuestionController
  only_set_object

  @model_class = QuestionItem
  @params_list = [:literal, :label, :instruction_id]
end
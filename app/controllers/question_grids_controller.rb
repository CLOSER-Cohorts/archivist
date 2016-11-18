class QuestionGridsController < QuestionController
  only_set_object

  @model_class = QuestionGrid
  @params_list = [
      :literal,
      :label,
      :instruction_id,
      :vertical_code_list_id,
      :horizontal_code_list_id,
      :roster_rows,
      :roster_label,
      :corner_label
  ]
end
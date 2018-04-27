# A controller for the model {QuestionGrid}
class QuestionGridsController < QuestionController
  # Initialise finding object for item based actions
  only_set_object

  # Set model for automatic CRUD actions
  @model_class = QuestionGrid

  # List of params that can be set and edited
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
# A controller for the model {QuestionItem}
class QuestionItemsController < QuestionController
  # Initialise finding object for item based actions
  only_set_object

  # Set model for automatic CRUD actions
  @model_class = QuestionItem

  # List of params that can be set and edited
  @params_list = [:literal, :label, :instruction_id]
end
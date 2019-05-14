# A controller for the model {CcStatement}
class CcStatementsController < ConstructController
  # Initialise finding object for item based actions
  only_set_object

  # Set model for automatic CRUD actions
  @model_class = CcStatement

  # List of params that can be set and edited
  @params_list = [:id, :literal]
end

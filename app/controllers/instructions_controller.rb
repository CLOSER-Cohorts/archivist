# A vanilla CRUD controller for the {Instruction} model
class InstructionsController < BasicInstrumentController
  # Initialise finding object for item based actions
  only_set_object

  # Set model for automatic CRUD actions
  @model_class = Instruction

  # List of params that can be set and edited
  @params_list = [:text]
end
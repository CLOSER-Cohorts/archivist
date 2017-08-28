# A vanilla CRUD controller for the {ResponseUnit} model
class ResponseUnitsController < BasicInstrumentController
  # Initialise finding object for item based actions
  only_set_object

  # Set model for automatic CRUD actions
  @model_class = ResponseUnit

  # List of params that can be set and edited
  @params_list = [:label]
end
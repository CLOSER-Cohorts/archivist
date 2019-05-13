# A controller for the model {CcLoop}
class CcLoopsController < ConstructController
  # Allow topic linking
  include Linkable::Controller

  # Initialise finding object for item based actions
  only_set_object { %i{set_topic} }

  # Set model for automatic CRUD actions
  @model_class = CcLoop

  # List of params that can be set and edited
  @params_list = [:id, :loop_var, :start_val, :end_val, :loop_while]
end

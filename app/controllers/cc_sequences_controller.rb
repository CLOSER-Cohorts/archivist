# A controller for the model {CcSequence}
class CcSequencesController < ConstructController
  # Allow topic linking
  include Linkable::Controller

  # Initialise finding object for item based actions
  only_set_object { %i{set_topic} }

  # Set model for automatic CRUD actions
  @model_class = CcSequence

  # List of params that can be set and edited
  @params_list = [:id, :literal]
end

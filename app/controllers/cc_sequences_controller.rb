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

  def index
    # Always make sure there is a top sequence so that we can
    # build a tree of sequences.
    if collection.first.children.count == 0
      top_sequence = collection.create!(parent: collection.first, label: @instrument.prefix)
    end
    super
  end
end

# A controller for the model {Topic}
class TopicsController < BasicController
  # Initialise finding object for item based actions
  only_set_object { %i{ question_statistics variable_statistics } }

  # Set model for automatic CRUD actions
  @model_class = Topic

  # List of params that can be set and edited
  @params_list = [:name, :parent_id, :code]

  # Loads the full {Topic} tree nested and in order
  #
  # Example:
  #   GET /topics/nested_index.json
  def nested_index
    @collection = collection.where parent_id: nil
  end

  # Loads the full {Topic} list, flattened, but in order
  #
  # Example:
  #   GET /topics/flattened_nest.json
  def flattened_nest
    @collection = Topic.flattened_nest
    render :index
  end

  # Loads summary statistics for {Topic} to {CcQuestion} mapping
  #
  # Example:
  #   GET /topics/1/question_statistics.json
  def question_statistics
  end

  # Loads summary statistics for {Topic} to {Variable} mapping
  #
  # Example:
  #   GET /topics/1/variable_statistics.json
  def variable_statistics
  end
end
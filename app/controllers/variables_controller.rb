class VariablesController < BasicController
  prepend_before_action :set_dataset
  only_set_object { %i{set_topic} }

  @model_class = Variable
  @params_list = [:name, :label, :var_type, :dataset_id]

  def set_topic
    topic = Topic.find params[:topic_id]

    begin
      @object.topic = topic
      @object.save!
      head :ok
    rescue Exceptions::TopicConflictError => e
      render json: {message: 'Could not set topic as it would cause a conflict.'}, status: :conflict
    rescue => e
      render json: e, status: :bad_request
    end
  end
  protected
  def collection
    @dataset.variables
  end

  def set_dataset
    @dataset = policy_scope(Dataset).find(params[:dataset_id])
  end
end
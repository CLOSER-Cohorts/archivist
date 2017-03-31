class VariablesController < BasicController
  prepend_before_action :set_dataset
  only_set_object { %i{set_topic} }

  @model_class = Variable
  @params_list = [:name, :label, :var_type, :dataset_id]

  protected
  def collection
    @dataset.variables
  end

  def set_dataset
    @dataset = policy_scope(Dataset).find(params[:dataset_id])
  end

  def set_topic
    topic = Topic.find params[:topic_id]
    @object.topic = topic
    @object.save!

    head :ok
  end
end
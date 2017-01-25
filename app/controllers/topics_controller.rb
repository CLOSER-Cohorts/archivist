class TopicsController < BasicController
  only_set_object

  @model_class = Topic
  @params_list = [:name, :parent_id, :code]

  def nested_index
    @collection = collection.where parent_id: nil
  end

  def flattened_nest
    @collection = Topic.flattened_nest
    render :index
  end
end
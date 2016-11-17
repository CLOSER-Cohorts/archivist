class TopicsController < BasicController
  only_set_object

  @model_class = Topic
  @params_list = [:name, :parent_id, :code]
end
class DatasetsController < BasicController
  only_set_object

  @model_class = Dataset
  @params_list = [:name]
end
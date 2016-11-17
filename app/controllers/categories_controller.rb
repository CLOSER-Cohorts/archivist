class CategoriesController < BasicInstrumentController
  only_set_object

  @model_class = Category
  @params_list = [:label]
end

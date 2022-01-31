# frozen_string_literal: true

# A vanilla CRUD controller for the {Category} model
class CategoriesController < BasicInstrumentController
  # Initialise finding object for item based actions
  only_set_object

  # Set model for automatic CRUD actions
  @model_class = Category

  # List of params that can be set and edited
  @params_list = [:label]
end

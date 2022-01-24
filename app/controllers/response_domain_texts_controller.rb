# frozen_string_literal: true

# A vanilla CRUD controller for the {ResponseDomainText} model
class ResponseDomainTextsController < BasicInstrumentController
  # Initialise finding object for item based actions
  only_set_object

  # Set model for automatic CRUD actions
  @model_class = ResponseDomainText

  # List of params that can be set and edited
  @params_list = [:label, :maxlen]
end
# A controller for the model {ResponseDomainNumeric}
class ResponseDomainNumericsController < BasicInstrumentController
  # The response domain has a subtype
  include RdSubtypeShim

  # Initialise finding object for item based actions
  only_set_object

  # Specifies the name of the subtype
  permit_subtype :numeric_type

  # Set model for automatic CRUD actions
  @model_class = ResponseDomainNumeric

  # List of params that can be set and edited
  @params_list = [:numeric_type, :label, :min, :max]
end
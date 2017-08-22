# A controller for the model {ResponseDomainDatetime}
class ResponseDomainDatetimesController < BasicInstrumentController
  # The response domain has a subtype
  include RdSubtypeShim

  # Initialise finding object for item based actions
  only_set_object

  # Specifies the name of the subtype
  permit_subtype :datetime_type

  # Set model for automatic CRUD actions
  @model_class = ResponseDomainDatetime

  # List of params that can be set and edited
  @params_list = [:datetime_type, :label, :format]
end
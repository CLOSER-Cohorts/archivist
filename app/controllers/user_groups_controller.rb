# frozen_string_literal: true

# A controller for the model {UserGroup}
class UserGroupsController < BasicController
  # Initialise finding object for item based actions
  only_set_object

  # Set model for automatic CRUD actions
  @model_class = UserGroup

  # List of params that can be set and edited
  @params_list = [:group_type, :label, :study => [:label]]

  # A public method to all the loading of basic {UserGroup} information
  # for sign-up.
  #
  # Example:
  #   GET /user_groups/external.json
  def external
    @collection = UserGroup.all
  end
end
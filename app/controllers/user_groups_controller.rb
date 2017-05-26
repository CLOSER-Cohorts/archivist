class UserGroupsController < BasicController
  only_set_object

  @model_class = UserGroup
  @params_list = [:group_type, :label, :study => [:label]]

  def external
    @collection = UserGroup.all
  end
end
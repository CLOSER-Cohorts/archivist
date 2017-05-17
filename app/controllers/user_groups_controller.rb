class UserGroupsController < BasicController
  only_set_object

  @model_class = Group
  @params_list = [:group_type, :label, :study => [:label]]

  def external
    @collection = Group.all
  end
end
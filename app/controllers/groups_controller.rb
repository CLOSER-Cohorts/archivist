class GroupsController < ApplicationController
  include BaseController

  add_basic_actions require: ':group',
                    params: ':group_type, :label, :study => [:label]',
                    collection: 'policy_scope(Group.all)'

  def external
    @collection = Group.all
  end
end
class GroupsController < ApplicationController
  include BaseController

  add_basic_actions require: ':group',
                    params: '[:group_type, :study, :label]',
                    collection: 'policy_scope(Group.all)'

end
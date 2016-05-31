class TopicsController < ApplicationController
  include BaseController

  add_basic_actions require: ':topic',
                    params: '[:name, :parent_id, :code]',
                    collection: 'policy_scope(Topic.all)'

end
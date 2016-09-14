class TopicsController < ApplicationController
  include BaseController

  add_basic_actions require: ':topic',
                    params: '[:name, :parent_id, :code]',
                    collection: 'policy_scope(Topic.all)'

  def nested_index
    @collection = collection.where parent_id: nil
  end

  def flattened_nest
    @collection = Topic.flattened_nest
    render :index
  end
end
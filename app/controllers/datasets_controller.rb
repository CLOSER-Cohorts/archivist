class DatasetsController < ApplicationController
  include BaseController

  add_basic_actions require: ':dataset',
                    params: '[:name]',
                    collection: 'policy_scope(Dataset.all)'

  def index
    super
    var_counts = Variable.group(:dataset_id).count
    @collection.each { |d| d.var_count = var_counts[d.id] }
  end
end
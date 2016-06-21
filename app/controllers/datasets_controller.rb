class DatasetsController < ApplicationController
  include BaseController

  add_basic_actions require: ':dataset',
                    params: '[:name]',
                    collection: 'policy_scope(Dataset.all)'

end
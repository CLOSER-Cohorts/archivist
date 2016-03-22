class DatasetsController < ApplicationController
  include BaseController

  add_basic_actions require: ':dataset',
                    params: '[:name]',
                    collection: 'Dataset.all'

end
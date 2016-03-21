class VariablesController < ApplicationController
  include BaseController

  add_basic_actions require: ':variable',
                    params: '[:name, :label, :var_type, :dataset_id]',
                    collection: 'Variable.all'

end
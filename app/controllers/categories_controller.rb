class CategoriesController < ApplicationController
  include BaseController

  add_basic_actions require: ':category',
                    params: '[:labels]',
                    collection: 'Instrument.find(params[:instrument_id]).categories'

end

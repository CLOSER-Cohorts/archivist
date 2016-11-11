class CategoriesController < ApplicationController
  include BaseInstrumentController

  add_basic_actions require: ':category',
                    params: '[:label]',
                    collection: 'Instrument.find(Prefix[params[:instrument_id]]).categories'

end

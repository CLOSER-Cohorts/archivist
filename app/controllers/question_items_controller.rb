class QuestionItemsController < ApplicationController
  include BaseInstrumentController

  add_basic_actions require: ':question_item',
                    params: '[:literal, :label, :instruction_id]',
                    collection: 'Instrument.find(params[:instrument_id]).question_items'

end
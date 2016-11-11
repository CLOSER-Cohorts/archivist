class QuestionItemsController < ApplicationController
  include Question::Controller

  add_basic_actions require: ':question_item',
                    params: '[:literal, :label, :instruction_id]',
                    collection: 'Instrument.find(Prefix[params[:instrument_id]]).question_items'



end
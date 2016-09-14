class CcQuestionsController < ApplicationController
  include Construct::Controller

  add_basic_actions require: ':cc_question',
                    params: '[:label, :question_id, :question_type, :response_unit_id, :topic, :parent, :position, :branch]',
                    collection: 'Instrument.find(params[:instrument_id]).cc_questions'

end
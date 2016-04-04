class CcQuestionsController < ApplicationController
  include BaseInstrumentController

  add_basic_actions require: ':cc_question',
                    params: '[:question_id, :question_type, :response_unit_id]',
                    collection: 'Instrument.find(params[:instrument_id]).cc_questions'

end
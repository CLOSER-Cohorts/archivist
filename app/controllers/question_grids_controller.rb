class QuestionGridsController < ApplicationController
  include BaseController

  add_basic_actions require: ':question_grid',
                    params: '[:literal, :label, :instruction_id, :vertical_code_list_id, :horizontal_code_list_id, :roster_rows, :roster_label, :corner_label]',
                    collection: 'Instrument.find(params[:instrument_id]).question_grids'

end
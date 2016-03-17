class QuestionGrid < ActiveRecord::Base
  include Question
  belongs_to :vertical_code_list, class_name: 'CodeList'
  belongs_to :horizontal_code_list, class_name: 'CodeList'

  URN_TYPE = 'qg'
  TYPE = 'QuestionGrid'
end

class QuestionGrid < ActiveRecord::Base
  belongs_to :instruction
  belongs_to :vertical_code_list, class_name: 'CodeList'
  belongs_to :horizontal_code_list, class_name: 'CodeList'
end

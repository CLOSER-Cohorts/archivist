class QuestionGrid < ActiveRecord::Base
  include Question::Model
  belongs_to :vertical_code_list, class_name: 'CodeList'
  belongs_to :horizontal_code_list, class_name: 'CodeList'

  URN_TYPE = 'qg'
  TYPE = 'QuestionGrid'

  def pretty_corner_label
    if corner_label == 'V'
      vertical_code_list.label
    elsif corner_label == 'H'
      horizontal_code_list.label
    else
      nil
    end
  end
end

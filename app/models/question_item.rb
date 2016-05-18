class QuestionItem < ActiveRecord::Base
  include Question::Model

  URN_TYPE = 'qi'
  TYPE = 'QuestionItem'
end

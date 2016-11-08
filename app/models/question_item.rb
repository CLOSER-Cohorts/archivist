class QuestionItem < ApplicationRecord
  include Question::Model

  URN_TYPE = 'qi'
  TYPE = 'QuestionItem'
end

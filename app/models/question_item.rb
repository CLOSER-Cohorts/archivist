class QuestionItem < ActiveRecord::Base
  include Question

  URN_TYPE = 'qi'
  TYPE = 'QuestionItem'
end

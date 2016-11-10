class QuestionItem < ApplicationRecord
  include Question::Model

  URN_TYPE = 'qi'
  TYPE = 'QuestionItem'

  def response_domains
    self.rds_qs.order(:rd_order).includes(:response_domain).map &:response_domain
  end
end

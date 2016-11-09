class QuestionItem < ApplicationRecord
  include Question::Model

  URN_TYPE = 'qi'
  TYPE = 'QuestionItem'

  def response_domains
    (self.response_domain_codes.to_a + self.response_domain_datetimes.to_a +
        self.response_domain_numerics.to_a + self.response_domain_texts.to_a).sort do |a,b|

      RdsQs.find_by(
          question_id: self.id,
          question_type: self.class.name,
          response_domain_id: a.id,
          response_domain_type: a.class.name
      ).rd_order <=> RdsQs.find_by(
          question_id: self.id,
          question_type: self.class.name,
          response_domain_id: b.id,
          response_domain_type: b.class.name
      ).rd_order
    end
  end
end

module Question
  extend ActiveSupport::Concern
  included do
    belongs_to :instruction
    has_many :rds_qs, class_name: 'RdsQs', as: :response_domain
    has_many :response_domain_codes, through: :rds_qs, source: :question, source_type: 'ResponseDomainCode'
    has_many :response_domain_datetimes, through: :rds_qs, source: :question, source_type: 'ResponseDomainDatetime'
    has_many :response_domain_numerics, through: :rds_qs, source: :question, source_type: 'ResponseDomainNumeric'
    has_many :response_domain_texts, through: :rds_qs, source: :question, source_type: 'ResponseDomainText'
  
    def response_domains
      self.response_domain_codes.to_a + self.response_domain_datetimes.to_a + 
      self.response_domain_numerics.to_a + self.response_domain_texts.to_a
    end
  end
end
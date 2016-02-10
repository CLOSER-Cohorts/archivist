module Question
  extend ActiveSupport::Concern
  included do
    belongs_to :instrument
    belongs_to :instruction
    has_many :rds_qs, class_name: 'RdsQs', as: :question, dependent: :destroy
    has_many :response_domain_codes, through: :rds_qs, source: :response_domain, source_type: 'ResponseDomainCode'
    has_many :response_domain_datetimes, through: :rds_qs, source: :response_domain, source_type: 'ResponseDomainDatetime'
    has_many :response_domain_numerics, through: :rds_qs, source: :response_domain, source_type: 'ResponseDomainNumeric'
    has_many :response_domain_texts, through: :rds_qs, source: :response_domain, source_type: 'ResponseDomainText'
    has_many :cc_questions, as: :question

    include Realtime

    alias constructs cc_questions

    def response_domains
      self.response_domain_codes.to_a + self.response_domain_datetimes.to_a +
          self.response_domain_numerics.to_a + self.response_domain_texts.to_a
    end
  end
end
module ResponseDomain
  extend ActiveSupport::Concern
  included do
    has_many :rds_qs, class_name: 'RdsQs', as: :response_domain, dependent: :destroy
    has_many :question_items, through: :rds_qs, source: :question, source_type: 'QuestionItem'
    has_many :question_grids, through: :rds_qs, source: :question, source_type: 'QuestionGrid'

    include Realtime

    def questions
      self.question_items.to_a + self.question_grids.to_a
    end
  end
end
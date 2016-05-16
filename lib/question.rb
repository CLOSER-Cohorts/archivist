module Question
end

module Question::Model
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

    def instruction=(text)
      if text.nil?
        self.instruction = nil
      else
        if self.instruction.nil?
          association(:instruction).writer Instruction.new text: text, instrument: self.instrument
        else
          association(:instruction).reader().text = text
        end
      end
    end
  end
end

module Question::Controller
  extend ActiveSupport::Concern
  include BaseInstrumentController
  included do
  end

  module ClassMethods
    def add_basic_actions(options = {})
      super options
      include Question::Controller::Actions
    end
  end

  module Actions
    def create
      @object = collection.new(safe_params)
      if @object.save
        if params.has_key? :instruction
          @object.instruction = params[:instruction]
          @object.save!
        end
        render :show, status: :created
      else
        render json: @object.errors, status: :unprocessable_entity
      end
    end
  end
end
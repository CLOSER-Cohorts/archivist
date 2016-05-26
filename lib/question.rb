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
      if text.nil? || text == ""
        association(:instruction).writer nil
      else
        association(:instruction).writer Instruction.new text: text, instrument: self.instrument
      end
    end

    def update_rds(rds)
      self.response_domains.each do |rd|
        matching = rds.select { |x| x[:id] == rd[:id] && x[:type] == rd.class.name }
        if matching.count == 0
          #ResponseDomain is no longer included
          rd.rds_qs.where(question_type: self.class.name, question_id: self.id).each {|x| x.destroy}
        else
          #TODO: Throw a wobbler
        end
      end
      self.reload

      unless rds.nil?
        if self.response_domains.length < rds.length
          # There are rds to add
          o_rds = rds.map { |x| x[:type].constantize.find(x[:id]) }
          new_rds = o_rds.reject { |x| self.response_domains.include? x }
          new_rds.each do |new_rd|
            association(new_rd.class.name.tableize).reader << new_rd
          end

        elsif self.response_domains.length > rds.length
          #TODO: Throw a massive wobbler
        end
      end
      self.reload
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

    def update
      if @object.update(safe_params)
        if params.has_key? :instruction
          @object.instruction = params[:instruction]
          @object.save!
        end
        if params.has_key? :rds
          @object.update_rds params[:rds]
          @object.save!
        end
        render :show, status: :ok
      else
        render json: @object.errors, status: :unprocessable_entity
      end
    end
  end
end
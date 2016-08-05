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

    include Realtime::RtUpdate

    alias constructs cc_questions

    def response_domains
      (self.response_domain_codes.to_a + self.response_domain_datetimes.to_a +
          self.response_domain_numerics.to_a + self.response_domain_texts.to_a).sort do |a,b|
            alpha = RdsQs.find_by(question_id: self.id, question_type: self.class.name, response_domain_id: a.id, response_domain_type: a.class.name).rd_order
            beta = RdsQs.find_by(question_id: self.id, question_type: self.class.name, response_domain_id: b.id, response_domain_type: b.class.name).rd_order
            alpha <=> beta
          end
    end

    def instruction=(text)
      if text.nil? || text == ""
        association(:instruction).writer nil
      else
        if association(:instruction).reader.nil? || association(:instruction).reader.text != text
          if (instruction = self.instrument.instructions.find_by_text(text)).nil?
            association(:instruction).writer Instruction.new text: text, instrument: self.instrument
          else
            association(:instruction).writer instruction
          end
        end
      end
    end

    def update_cols(cols)
      if cols.nil? || cols.empty?
        self.rds_qs.delete_all
      else
        cols.sort_by! { |x| x[:order] }
        cols.each do |col|
          if col[:rd].nil?
            rd = self.rds_qs.find_by_code_id col[:value]
            rd.delete unless rd.nil?
          else
            rd = self.instrument.association(col[:rd][:type].tableize).reader.find col[:rd][:id]
            self.rds_qs.create question: self, response_domain: rd, code_id: col[:value], instrument_id: self.instrument_id
          end
        end
      end
    end

    def update_rds(rds)
      if rds.nil?
        self.response_domain_codes =
        self.response_domain_datetimes =
        self.response_domain_numerics =
        self.response_domain_texts = []
      else
        rds.each_index { |i| rds[i][:rd_order] = i + 1 }
        self.transaction do
          self.response_domains.each do |rd|
            index = rds.index { |x| x[:id] == rd[:id] && x[:type] == rd.class.name }
            if index.nil?
              #ResponseDomain is no longer included
              rd.rds_qs.where(question_type: self.class.name, question_id: self.id).each {|x| x.destroy}
            else
              joint = rd.rds_qs.where(question_type: self.class.name, question_id: self.id).first
              joint.rd_order = rds[index][:rd_order]
              joint.save!
            end
          end
        end
        self.reload

        if self.response_domains.length < rds.length
          # There are rds to add
          if self.rds_qs.length < 1
            highest_rd_order = 0
          else
            highest_rd_order = self.rds_qs.order(:rd_order).last.rd_order
          end
          o_rds = rds.map { |x| x[:type].constantize.find(x[:id]) }
          new_rds = o_rds.reject { |x| self.response_domains.include? x }
          new_rds.each do |new_rd|
            highest_rd_order += 1
            RdsQs.create instrument_id: self.instrument_id,
                         response_domain: new_rd,
                         question: self,
                         rd_order: highest_rd_order
            #association(new_rd.class.name.tableize).reader << new_rd
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
      update_question @object = collection.new(safe_params) do |obj|
        obj.save
      end
    end

    def update
      update_question @object do |obj|
        obj.update(safe_params)
      end
    end

    private
    def update_question object, &block
      if block.call object
        if params.has_key? :instruction
          object.instruction = params[:instruction]
          object.save!
        end
        if params.has_key? :rds
          object.update_rds params[:rds]
          object.save!
        end
        if params.has_key? :cols
          object.update_cols params[:cols]
          object.save!
        end
        render :show, status: :ok
      else
        render json: @object.errors, status: :unprocessable_entity
      end
    end
  end
end
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
    has_many :cc_questions, as: :question, dependent: :destroy

    include Realtime::RtUpdate
    include Exportable
    # This model can be tracked using an Identifier
    include Identifiable

    NS ||= 'd'

    before_create :no_duplicates
    #validates :label, uniqueness: { scope: :instrument_id }

    alias constructs cc_questions

    def instruction=(text)
      if text.nil? || text == ''
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
            self.rds_qs.create question: self, response_domain: rd, code_id: col[:value], instrument_id: Prefix[self.instrument_id]
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
          add_rds rds
        end
      end
      self.reload
    end

    def add_rds(rds)
      if self.rds_qs.length < 1
        highest_rd_order = 0
      else
        highest_rd_order = self.rds_qs.order(:rd_order).last.rd_order
      end
      o_rds = rds.map { |x| x[:type].constantize.find(x[:id]) }
      new_rds = o_rds.reject { |x| self.response_domains.include? x }
      new_rds.each do |new_rd|
        highest_rd_order += 1
        RdsQs.create instrument_id: Prefix[self.instrument_id],
                     response_domain: new_rd,
                     question: self,
                     rd_order: highest_rd_order
      end
    end

    private
    def no_duplicates
      until self.instrument.send(self.class.name.tableize.to_sym).find_by_label(self.label).nil?
        self.label += '_dup'
      end
    end
  end
end
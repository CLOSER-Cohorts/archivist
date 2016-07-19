class Instrument < ActiveRecord::Base

  has_many :cc_conditions, -> { includes :cc }, dependent: :destroy
  has_many :cc_loops, -> { includes :cc }, dependent: :destroy
  has_many :cc_questions, -> { includes :cc }, dependent: :destroy
  has_many :cc_sequences, -> { includes :cc }, dependent: :destroy
  has_many :cc_statements, -> { includes :cc }, dependent: :destroy

  has_many :question_grids, -> { includes [
                                              :response_domain_datetimes,
                                              :response_domain_numerics,
                                              :response_domain_texts,
                                              response_domain_codes: [
                                                  code_list: [
                                                      codes: [
                                                          :category
                                                      ]
                                                  ]
                                              ],
                                              vertical_code_list: [
                                                  codes: [
                                                      :category
                                                  ]
                                              ],
                                              horizontal_code_list: [
                                                  codes: [
                                                      :category
                                                  ]
                                              ]
                                          ] }, dependent: :destroy
  has_many :question_items, -> { includes [
                                              :response_domain_datetimes,
                                              :response_domain_numerics,
                                              :response_domain_texts,
                                              response_domain_codes: [
                                                  code_list: [
                                                      codes: [
                                                          :category
                                                      ]
                                                  ]
                                              ]
                                          ] }, dependent: :destroy

  has_many :code_lists, dependent: :destroy
  has_many :categories, dependent: :destroy

  has_many :instructions, dependent: :destroy

  has_many :response_domain_datetimes, dependent: :destroy
  has_many :response_domain_numerics, dependent: :destroy
  has_many :response_domain_texts, dependent: :destroy
  has_many :response_units, dependent: :destroy

  has_many :instruments_datasets, class_name: 'InstrumentsDatasets'
  has_many :datasets, through: :instruments_datasets

  include Realtime::RtUpdate

  after_create :add_top_sequence

  def conditions
    self.cc_conditions
  end

  def loops
    self.cc_loops
  end

  def questions
    self.cc_questions
  end

  def sequences
    self.cc_sequences
  end

  def statements
    self.cc_statements
  end

  def codes
    Code.joins(:code_list).where instrument_id: id
  end

  def response_domain_codes
    ResponseDomainCode.includes(:code_list).joins(:code_list).where instrument_id: id
  end

  def response_domains
    self.response_domain_datetimes.to_a + self.response_domain_numerics.to_a +
        self.response_domain_texts.to_a + self.response_domain_codes.to_a
  end

  def ccs
    self.cc_conditions.to_a + self.cc_loops.to_a + self.cc_questions.to_a +
        self.cc_sequences.to_a + self.cc_statements.to_a
  end

  def top_sequence
    self
        .cc_sequences
        .joins('INNER JOIN control_constructs as cc ON cc_sequences.id = cc.construct_id AND cc.construct_type = \'CcSequence\'')
        .where('cc.parent_id IS NULL')
        .first
  end

  def ccs_in_ddi_order
    output = []
    harvest = lambda do |parent|
      output.append parent
      if parent.class.method_defined? :children
        parent.children.each { |child| harvest.call child.construct }
      end
    end
    harvest.call self.top_sequence
    output
  end

  def add_top_sequence
    self.cc_sequences.create
  end

  def copy
    #original = Instrument.find original_id
    #Deep copy all components, including those not directly
    #referenced like ResponseDomainCodes
  end

  def cc_count
    stats = self.association_stats
    stats['cc_conditions'] + stats['cc_loops'] + stats['cc_questions'] +
        stats['cc_sequences'] + stats['cc_statements']
  end
end

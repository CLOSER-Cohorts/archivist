class CodeList < ApplicationRecord
  belongs_to :instrument
  has_many :codes, -> { includes(:category).order('"order" ASC') }, dependent: :destroy
  has_many :categories, through: :codes
  has_one :response_domain_code, dependent: :destroy
  has_many :qgrids_via_h, class_name: 'QuestionGrid', foreign_key: 'horizontal_code_list_id'
  has_many :qgrids_via_v, class_name: 'QuestionGrid', foreign_key: 'vertical_code_list_id'

  include Realtime::RtUpdate
  include Exportable

  URN_TYPE = 'cl'
  TYPE = 'CodeList'

  before_create :no_duplicates

  def response_domain
    self.response_domain_code
  end

  def response_domain=(be_code_answer)
    if be_code_answer && response_domain.nil?
      self.response_domain_code = ResponseDomainCode.new instrument_id: self.instrument_id
    end

    unless be_code_answer || response_domain.nil?
      self.response_domain_code.delete
    end
  end

  def question_grids
    self.qgrids_via_h.to_a + self.qgrids_via_v.to_a
  end

  def used_by
    if self.response_domain.nil?
      self.question_grids
    else
      self.response_domain.questions + self.question_grids
    end
  end

  def update_codes(codes)
    logger.debug codes
    #Check current codes against what was returned
    self.codes.each do |code|
      matching = codes.select { |x| x[:id] == code[:id] }
      if matching.count == 0
        #Code is no longer included
        #TODO: What implications does destroying a code have for grid axises?
        code.destroy
      elsif matching.count == 1
        code.order = matching.first[:order]
        code.value = matching.first[:value]
        code.label = matching.first[:label]
        code.save!
      else
        #TODO: Throw a wobbler
      end
    end

    unless codes.nil?
      self.codes.reload
      if self.codes.length < codes.length
        # There are codes to add
        new_codes_values = codes.select { |x| x[:id].nil? }
        new_codes_values.each do |new_code_values|
          unless new_code_values[:value].to_s == '' || new_code_values[:label].to_s == ''
            new_code = Code.new
            new_code.order = new_code_values[:order]
            new_code.value = new_code_values[:value]
            new_code.set_label new_code_values[:label], self.instrument
            self.codes << new_code
          end
        end

      elsif self.codes.length > codes.length
        #TODO: Throw a massive wobbler
      end
    end
    self.reload
  end

  private
  def no_duplicates
    until self.instrument.code_lists.find_by_label(self.label).nil?
      self.label += '_dup'
    end
  end
end

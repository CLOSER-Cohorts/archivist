# The CodeList is based on the CodeList model from DDI3.X
#
# A CodeList has a label and typically pulls together multiple {Code Codes} to
# create either a {QuestionGrid} axis or a {ResponseDomain}.
#
# Please visit http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/logicalproduct_xsd/elements/CodeList.html
#
# === Properties
# * Label
class CodeList < ApplicationRecord
  # This model is exportable as DDI
  include Exportable

  # This model is an update point for archivist-realtime
  include Realtime::RtUpdate

  # Used to create CLOSER UserID and URNs
  URN_TYPE = 'cl'

  # XML tag name
  TYPE = 'CodeList'

  # Before creating a new model in the database, check whether this would be a duplicate
  before_create :no_duplicates

  # All categories must belong to an instrument
  belongs_to :instrument

  # Each CodeList can have multiple {Code Codes}
  has_many :codes, -> { includes(:category).order('"order" ASC') }, dependent: :destroy

  # Each CodeList can have multiple {Category Categories} through a {Code} as a
  # many-to-many relationship
  has_many :categories, through: :codes

  # Every {QuestionGrid} where this CodeList was used as a horizontal axis
  #
  # Horizontal axis is considered to be rank 2 in DDI
  has_many :qgrids_via_h, class_name: 'QuestionGrid', foreign_key: 'horizontal_code_list_id'

  # Every {QuestionGrid} where this CodeList was used as a vertical axis
  #
  # Vertical axis is considered to be rank 1 in DDI
  has_many :qgrids_via_v, class_name: 'QuestionGrid', foreign_key: 'vertical_code_list_id'

  # Each CodeList can optionally be represented as a {ResponseDomainCode}
  has_one :response_domain_code, dependent: :destroy

  # Returns all the {QuestionGrid QuestionGrids} that this CodeList has been
  # used as an axis in
  #
  # @return [Array]
  def question_grids
    self.qgrids_via_h.to_a + self.qgrids_via_v.to_a
  end

  # Gets the associatedd {ResponseDomainCode}
  #
  # Returns nil if CodeList is not also a {ResponseDomain}
  #
  # @return [ResponseDomainCode]
  def response_domain
    self.response_domain_code
  end

  # Sets wheather CodeList should be a {ResponseDomainCode}
  #
  # @param [Object] be_code_answer True/False whether CodeList should be used as a {ResponseDomain}
  def response_domain=(be_code_answer)
    if be_code_answer && response_domain.nil?
      self.response_domain_code = ResponseDomainCode.new instrument_id: self.instrument_id
    end

    unless be_code_answer || response_domain.nil?
      self.response_domain_code.delete
    end
  end

  # Update the {Code Codes} attached to this CodeList using an array of
  # {Code Codes} given
  #
  # This function can handle creating, editting and deleting {Code Codes}
  #
  # @param [Array] codes List of {Code Codes} to transform the existing {Code Codes} to
  def update_codes(codes)
    #Check current codes against what was passed
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

  # Returns an array of all objects that use this CodeList
  #
  # @return [Array]
  def used_by
    if self.response_domain.nil?
      self.question_grids
    else
      self.response_domain.questions + self.question_grids
    end
  end

  private # Private methods

  # Checks whether the CodeList label is already in use
  #
  # If the label is already in use then '_dup' is added and the process
  # is repeated until the CodeList can be created.
  def no_duplicates
    until self.instrument.code_lists.find_by_label(self.label).nil?
      self.label += '_dup'
    end
  end
end

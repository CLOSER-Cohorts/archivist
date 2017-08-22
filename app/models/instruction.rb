# The Instruction is based on the InterviewerInstruction model from DDI3.X
#
# A Instruction has a label and represents instructive text the is delivered
# with either a {QuestionGrid} or a {QuestionItem}.
#
# Please visit http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/logicalproduct_xsd/elements/CodeList.html
#
# === Properties
# * Label
class Instruction < ActiveRecord::Base
  # This model is exportable as DDI
  include Exportable

  # This model can be tracked using an Identifier
  include Identifiable

  # Used to create CLOSER UserID and URNs
  URN_TYPE = 'ii'

  # XML tag name
  TYPE = 'Instruction'

  # All categories must belong to an instrument
  belongs_to :instrument

  # Each instruction can be used for many {QuestionItems QuestionItem}
  has_many :question_items, dependent: :nullify

  # Each instruction can be used for many {QuestionGrids QuestionGrid}
  has_many :question_grids, dependent: :nullify

  # Returns an array of all questions where this instruction is used
  #
  # @returns [Array] All questions using this instruction
  def questions
    self.question_items.to_a + self.question_grids.to_a
  end
end

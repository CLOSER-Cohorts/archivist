# A representation of the database view for Q-V Mapping
#
# This cannot be used for creating, updating or deleting, but provides
# a quick way to view question-variable mapping.
#
# === Properties
# * id
# * source
# * variable
class QvMapping < ReadOnlyRecord
  # Use id as a primary key
  self.primary_key = :id

  # Each QV mapping can only belong to one {Dataset}
  belongs_to :dataset

  # Each QV mapping can only belong to one {Instrument}
  belongs_to :instrument

  delegate :control_construct_scheme, to: :instrument, allow_nil: true
  delegate :instance_name, to: :dataset, allow_nil: true, prefix: true

  # Return question reference with grid cell reference
  #
  # @return [String] Question reference
  def question_with_cell
    self.question + ((self.x.nil? || self.y.nil?) ? '' : "$#{self.x};#{self.y}")
  end
end

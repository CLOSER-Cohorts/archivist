# The QuestionGrid model directly relates to the DDI3.X QuestionGrid model
#
# Please visit http://www.ddialliance.org/Specification/DDI-Lifecycle/3.2/XMLSchema/FieldLevelDocumentation/schemas/datacollection_xsd/elements/QuestionGrid.html
#
# === Properties
# * Label
# * Literal
# * Roster Label
# * Roster Rows
# * Corner Label
class QuestionGrid < ApplicationRecord
  # This model has all the standard {Question::Model Question} features from DDI3.X
  include Question::Model

  # Used to create CLOSER UserID and URNs
  URN_TYPE = 'qg'

  # XML tag name
  TYPE = 'QuestionGrid'

  # Each QuestionGrid needs a {CodeList} to form the vertical axis
  belongs_to :vertical_code_list, class_name: 'CodeList'

  # Each QuestionGrid needs a {CodeList} to form the horizontal axis
  belongs_to :horizontal_code_list, class_name: 'CodeList'

  # Returns the number of columns
  #
  # @return [Integer] Number of columns
  def max_x
    horizontal_code_list.codes.size
  end

  # Returns the total number of rows, including the rosters
  #
  # @return [Integer] Number of rows
  def max_y
    vertical_code_list&.codes&.count.to_i + roster_rows.to_i
  end

  # Returns the display corner label
  #
  # @return [String] Corner label
  def pretty_corner_label
    if corner_label == 'V'
      vertical_code_list.label
    elsif corner_label == 'H'
      horizontal_code_list.label
    else
      nil
    end
  end

  # Returns all response domains in order
  #
  # @return [Array] All response domains
  def response_domains
    grid_rds_qs.map { |x| x.response_domain }
  end

  # Returns all grid rds_qs using horizontal_code_list_id
  #
  # @return [Array] All RdsQs
  def grid_rds_qs
    sql = <<~SQL
      SELECT rds_qs.*
      FROM rds_qs
      INNER JOIN question_grids
        ON question_grids.id = rds_qs.question_id
        AND rds_qs.question_type = 'QuestionGrid'
      INNER JOIN codes
        ON codes.code_list_id = question_grids.horizontal_code_list_id
        AND codes.value::int = rds_qs.code_id
      WHERE question_grids.id = ?
      ORDER BY codes.order
    SQL
    RdsQs.find_by_sql ([sql, self.id])
  end

  # Exports as an XML fragment
  #
  # @return [String] XML fragment
  def to_xml_fragment
    Exporters::XML::DDI::Fragment.export_3_2 Exporters::XML::DDI::QuestionGrid, self
  end
end

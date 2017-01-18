class QuestionGrid < ApplicationRecord
  include Question::Model
  belongs_to :vertical_code_list, class_name: 'CodeList'
  belongs_to :horizontal_code_list, class_name: 'CodeList'

  URN_TYPE = 'qg'
  TYPE = 'QuestionGrid'

  def pretty_corner_label
    if corner_label == 'V'
      vertical_code_list.label
    elsif corner_label == 'H'
      horizontal_code_list.label
    else
      nil
    end
  end

  def max_x
    horizontal_code_list.codes.count
  end

  def max_y
    vertical_code_list.codes.count
  end

  def response_domains
    sql = <<~SQL
          SELECT *
          FROM rds_qs
          INNER JOIN question_grids
          ON question_grids.id = rds_qs.question_id
            AND rds_qs.question_type = 'QuestionGrid'
          INNER JOIN codes
          ON codes.code_list_id = question_grids.horizontal_code_list_id
            AND codes.value = rds_qs.code_id::varchar(255)
          WHERE question_grids.id = ?
          ORDER BY codes.order
    SQL
    rds_qs = RdsQs.find_by_sql ([ sql, self.id])
    rds_qs.map { |x| x.response_domain }
  end

  def to_xml_fragment
    Exporters::XML::DDI::Fragment.export_3_2 Exporters::XML::DDI::QuestionGrid, self
  end
end

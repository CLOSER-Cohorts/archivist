json.array!(@collection) do |question_grid|
  json.extract! question_grid, :id, :label, :literal, :vertical_code_list_id, :horizontal_code_list_id, :roster_rows, :roster_label, :corner_label
  json.type question_grid.class.name
  json.instruction question_grid.instruction.nil? ? '' : question_grid.instruction.text
  begin
  json.cols question_grid.horizontal_code_list.codes do |x|
    json.label x.category.label
    json.order x.order
    json.value x.value
    json.rd do
      if question_grid.horizontal_code_list.codes.length > 1
        json.partial! 'response_domains/show',
                    rd: question_grid.rds_qs.find_by_code_id(x.value).nil? ?
                        nil : question_grid.rds_qs.find_by_code_id(x.value).response_domain
      else
        json.partial! 'response_domains/show', rd: question_grid.rds_qs.first.response_domain
      end
    end
  end
  json.rows question_grid.vertical_code_list.codes do |y|
    json.label y.category.label
    json.order y.order
  end
  json.pretty_corner_label question_grid.pretty_corner_label
  rescue
    json.error true
  end
end
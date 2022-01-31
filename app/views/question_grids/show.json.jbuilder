# frozen_string_literal: true

  json.extract! @object, :id, :label, :literal, :vertical_code_list_id, :horizontal_code_list_id, :roster_rows, :roster_label, :corner_label
  json.type @object.class.name
  json.instruction @object.instruction.nil? ? '' : @object.instruction.text
  begin
  json.cols @object.horizontal_code_list.codes do |x|
    json.label x.category.label
    json.order x.order
    json.value x.value
    json.rd do
      if @object.horizontal_code_list.codes.length > 1
        json.partial! 'response_domains/show',
                    rd: @object.rds_qs.find_by_code_id(x.value).nil? ?
                        nil : @object.rds_qs.find_by_code_id(x.value).response_domain
      else
        json.partial! 'response_domains/show', rd: @object.rds_qs.count < 1 ? nil : @object.rds_qs.first.response_domain
      end
    end
  end
  json.rows @object.vertical_code_list.codes do |y|
    json.label y.category.label
    json.order y.order
  end
  json.pretty_corner_label 'wtf'
  rescue
    json.error true
  end

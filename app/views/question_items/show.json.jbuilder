# frozen_string_literal: true

json.extract! @object, :id, :label, :literal, :instruction_id, :created_at, :updated_at
json.type @object.class.name
json.instruction @object.instruction.nil? ? '' : @object.instruction.text
json.rds @object.rds_qs.each do |rds_qs|
  begin
    rd = rds_qs.response_domain
    json.id rd.id
    json.rd_order rds_qs.rd_order
    json.type rd.class.name
    json.label rd.label
    if rd.class == ResponseDomainCode
      json.codes rd.codes, :label, :value, :order
      json.min_responses rd.min_responses
      json.max_responses rd.max_responses
    elsif rd.class == ResponseDomainText
      json.maxlen rd.maxlen
    else
      json.subtype rd.subtype
      json.params rd.params
    end
  rescue => err
    logger.warn 'response_domain id is nil'
    logger.warn err.message
  end
end

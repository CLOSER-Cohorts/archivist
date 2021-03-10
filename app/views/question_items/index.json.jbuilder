json.array!(@collection) do |question_item|
  json.extract! question_item, :id, :label, :literal
  json.type question_item.class.name
  json.instruction question_item.instruction.nil? ? '' : question_item.instruction.text
  json.rds question_item.rds_qs.each do |rds_qs|
    begin
      rd = case rds_qs.response_domain_type
           when "ResponseDomainCode"
              @response_domain_codes.find{|rdc| rdc.id == rds_qs.response_domain_id}
           when "ResponseDomainDatetime"
              @response_domain_datetimes.find{|rdc| rdc.id == rds_qs.response_domain_id}
           when "ResponseDomainNumeric"
              @response_domain_numerics.find{|rdc| rdc.id == rds_qs.response_domain_id}
           when "ResponseDomainText"
              @response_domain_texts.find{|rdc| rdc.id == rds_qs.response_domain_id}
           end
      json.id rd.id
      json.type rd.class.name
      json.label rd.label
      if rd.class == ResponseDomainCode
        json.codes rd.codes, :label, :value, :order
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
end

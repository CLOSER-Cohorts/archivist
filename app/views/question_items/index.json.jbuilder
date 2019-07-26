json.array!(@collection) do |question_item|
  json.extract! question_item, :id, :label, :literal
  json.type question_item.class.name
  json.instruction question_item.instruction.nil? ? '' : question_item.instruction.text
  json.rds question_item.response_domains do |rd|
    begin
      json.id rd.id
      json.type rd.class.name
      json.label rd.label
      if rd.class == ResponseDomainCode
        json.codes rd.codes, :label, :value, :order
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

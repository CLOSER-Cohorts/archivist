module Exporters::XML::DDI
  class QuestionItem < DdiExporterBase
    def initialize(doc)
      @doc = doc
    end

    def V3_2(qitem_id)
      if qitem_id.is_a? ::QuestionItem
        qitem = qitem_id
      else
        qitem = ::QuestionItem.find qitem_id
      end

      qi = Nokogiri::XML::Node.new 'd:QuestionItem', @doc
      urn = create_urn_node qitem
      qi.add_child urn
      uap = Nokogiri::XML::Node.new 'r:UserAttributePair', @doc
      uap.add_child "<r:AttributeKey>extension:Label</r:AttributeKey><r:AttributeValue>{\"en-GB\":\"%{label}\"}</r:AttributeValue>" %
                        {label: Util::question_label(qitem.label)}
      urn.add_next_sibling uap
      qin = Nokogiri::XML::Node.new 'd:QuestionItemName', @doc
      qin.add_child "<r:String xml:lang=\"en-GB\">%{label}</r:String>" %
                        {label: qitem.label}
      uap.add_next_sibling qin
      qt = Nokogiri::XML::Node.new 'd:QuestionText', @doc
      qt['audienceLanguage'] = 'en-GB'
      qt.add_child '<d:LiteralText><d:Text>%{text}</d:Text></d:LiteralText>' %
                       {text: CGI::escapeHTML(qitem.literal)}
      qin.add_next_sibling qt

      inner_prev = qt

      build_response_domain = lambda do |rd|
        case rd
          when ::ResponseDomainCode
            cd = Nokogiri::XML::Node.new 'd:CodeDomain', @doc
            cd.add_child create_reference_string 'r:CodeListReference', rd.code_list
            cd.add_child '<r:ResponseCardinality minimumResponses="%{min}" maximumResponses="%{max}"></r:ResponseCardinality>' % {
                min: rd.min_responses,
                max: rd.max_responses
            }

            return cd
          when ::ResponseDomainDatetime
            dd = Nokogiri::XML::Node.new 'd:DateTimeDomain', @doc
            dd.add_child "<r:DateFieldFormat>%{format}</r:DateFieldFormat><r:DateTypeCode>%{type}</r:DateTypeCode><r:Label><r:Content xml:lang=\"en-GB\">%{label}</r:Content></r:Label>" %
                             {label: rd.label, type: rd.datetime_type, format: rd.format || ''}

            return dd
          when ::ResponseDomainNumeric
            nd = Nokogiri::XML::Node.new 'd:NumericDomain', @doc
            nd.add_child "<r:NumberRange>%{range}</r:NumberRange><r:NumericTypeCode>%{type}</r:NumericTypeCode><r:Label><r:Content xml:lang=\"en-GB\">%{label}</r:Content></r:Label>" %
                             {label: rd.label, type: rd.numeric_type, range: (if rd.min then "<r:Low>%d</r:Low>" % rd.min else '' end) + (if rd.max then "<r:High>%d</r:High>" % rd.max else '' end)}


            return nd
          when ::ResponseDomainText
            td = Nokogiri::XML::Node.new 'd:TextDomain', @doc
            unless rd.maxlen.nil?
              td['maxLength'] = rd.maxlen
            end
            td.add_child "<r:Label><r:Content xml:lang=\"en-GB\">%{label}</r:Content></r:Label>" %
                             {label: rd.label}

            return td
        end
      end

      unless qitem.instruction.nil?
        iif = create_reference_string 'd:InterviewerInstructionReference', qitem.instruction
        inner_prev.add_next_sibling iif
      end

      if qitem.response_domains.count > 1
        smrd = Nokogiri::XML::Node.new 'd:StructuredMixedResponseDomain', @doc
        inner_prev.add_next_sibling smrd
        qitem.response_domains.each do |rd|
          rdm = Nokogiri::XML::Node.new 'd:ResponseDomainInMixed', @doc
          rdm.add_child build_response_domain.call rd
          smrd.add_child rdm
        end
      elsif qitem.response_domains.count == 1
        inner_prev.add_next_sibling build_response_domain.call qitem.response_domains.first
      end

      qi
    end
  end
end
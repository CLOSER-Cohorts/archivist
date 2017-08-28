module Exporters::XML::DDI
  # DDI 3.2 XML Exporter for {::QuestionItem}
  #
  # {::QuestionItem} is a direct alias of DDI 3.2 QuestionItem.
  #
  # === Example
  #   doc = Nokogiri::XML::Document.new
  #   qi = QuestionItem.first
  #   exporter = Exporters::XML::DDI::QuestionItem.new doc
  #   xml_node = exporter.V3_2(qi)
  #
  # @see ::QuestionItem
  class QuestionItem < Exporters::XML::DDI::Question
    # Exports the {::QuestionItem} in DDI 3.2
    #
    # Create a single XML node as an export of a single {::QuestionItem}.
    # In order to be valid DDI, this node then needs to be wrapped
    # either in a QuestionScheme or a Fragment.
    #
    # @param [::QuestionItem|Integer] qitem_id Either the QuestionItem or QuestionItem ID for exporting
    # @return [Nokogiri::XML::Node] New XML node
    def V3_2(qitem_id)
      @klass = ::QuestionItem

      super do |qitem, qi|
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

        if qitem.response_domains.count > 1
          smrd = Nokogiri::XML::Node.new 'd:StructuredMixedResponseDomain', @doc
          qi.add_child smrd
          qitem.response_domains.each do |rd|
            rdm = Nokogiri::XML::Node.new 'd:ResponseDomainInMixed', @doc
            rdm.add_child build_response_domain.call rd
            smrd.add_child rdm
          end
        elsif qitem.response_domains.count == 1
          qi.add_child build_response_domain.call qitem.response_domains.first
        end

        unless qitem.instruction.nil?
          iif = create_reference_string 'd:InterviewerInstructionReference', qitem.instruction
          qi.add_child iif
        end
      end
    end
  end
end
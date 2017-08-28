module Exporters::XML::DDI
  # DDI 3.2 XML Exporter for {::CcQuestion}
  #
  # {::CcQuestion} is a direct alias of DDI 3.2 QuestionConstruct.
  #
  # === Example
  #   doc = Nokogiri::XML::Document.new
  #   qc = CcQuestion.first
  #   exporter = Exporters::XML::DDI::CcQuestion.new doc
  #   xml_node = exporter.V3_2(qc)
  #
  # @see ::CcQuestion
  class CcQuestion < DdiExporterBase
    # Exports the {::CcQuestion} in DDI 3.2
    #
    # Create a single XML node as an export of a single {::CcQuestion}.
    # In order to be valid DDI, this node then needs to be wrapped
    # either in a ControlConstructScheme or a Fragment.
    #
    # @param [::CcQuestion|Integer] qc_id Either the CcQuestion or CcQuestion ID for exporting
    # @return [Nokogiri::XML::Node] New XML node
    def V3_2(qc_id)
      if qc_id.is_a? ::CcQuestion
        cc = qc_id
      else
        cc = ::CcQuestion.find qc_id
      end

      qc = Nokogiri::XML::Node.new 'd:QuestionConstruct', @doc
      urn = create_urn_node cc
      qc.add_child urn
      cn = Nokogiri::XML::Node.new 'd:ConstructName', @doc
      s = Nokogiri::XML::Node.new 'r:String', @doc
      s['xml:lang'] = 'en-GB'
      s.content = cc.label
      cn.add_child s
      qc.add_child cn

      l = Nokogiri::XML::Node.new 'r:Label', @doc
      c = Nokogiri::XML::Node.new 'r:Content', @doc
      c['xml:lang'] = 'en-GB'
      c.content = Util::question_label cc.label
      l.add_child c
      cn.add_next_sibling l

      qf = create_reference_string 'r:QuestionReference', cc.question
      ru = Nokogiri::XML::Node.new 'd:ResponseUnit', @doc
      ru.content = cc.response_unit.label
      l.add_next_sibling qf
      qf.add_next_sibling ru

      qc
    end
  end
end
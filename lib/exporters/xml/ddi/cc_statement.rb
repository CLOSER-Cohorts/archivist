module Exporters::XML::DDI
  # DDI 3.2 XML Exporter for {::CcStatement}
  #
  # {::CcStatement} is a direct alias of DDI 3.2 StatementItem.
  #
  # === Example
  #   doc = Nokogiri::XML::Document.new
  #   sta = CcStatement.first
  #   exporter = Exporters::XML::DDI::CcStatement.new doc
  #   xml_node = exporter.V3_2(sta)
  #
  # @see ::CcStatement
  class CcStatement < DdiExporterBase
    # Exports the {::CcStatement} in DDI 3.2
    #
    # Create a single XML node as an export of a single {::CcStatement}.
    # In order to be valid DDI, this node then needs to be wrapped
    # either in a ControlConstructScheme or a Fragment.
    #
    # @param [::CcStatement|Integer] sta_id Either the CcStatement or CcStatement ID for exporting
    # @return [Nokogiri::XML::Node] New XML node
    def V3_2(sta_id)
      if sta_id.is_a? ::CcStatement
        cc = sta_id
      else
        cc = ::CcStatement.find sta_id
      end

      st = Nokogiri::XML::Node.new 'd:StatementItem', @doc
      urn = create_urn_node cc
      st.add_child urn
      cn = Nokogiri::XML::Node.new 'd:ConstructName', @doc
      s = Nokogiri::XML::Node.new 'r:String', @doc
      s['xml:lang'] = 'en-GB'
      s.content = cc.label
      cn.add_child s
      st.add_child cn

      dt = Nokogiri::XML::Node.new 'd:DisplayText', @doc
      dt['audienceLanguage'] = 'en-GB'
      lt = Nokogiri::XML::Node.new 'd:LiteralText', @doc
      t = Nokogiri::XML::Node.new 'd:Text', @doc
      t.content = cc.literal
      lt.add_child t
      dt.add_child lt
      cn.add_next_sibling dt

      st
    end
  end
end
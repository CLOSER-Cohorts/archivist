module Exporters::XML::DDI
  # DDI 3.2 XML Exporter for {::CodeList}
  #
  # {::CodeList} is a direct alias of DDI 3.2 CodeList.
  #
  # === Example
  #   doc = Nokogiri::XML::Document.new
  #   cl = CodeList.first
  #   exporter = Exporters::XML::DDI::CodeList.new doc
  #   xml_node = exporter.V3_2(cl)
  #
  # @see ::CodeList
  class CodeList < DdiExporterBase
    # Exports the {::CodeList} in DDI 3.2
    #
    # Create a single XML node as an export of a single {::CodeList}.
    # In order to be valid DDI, this node then needs to be wrapped
    # either in a CodeListScheme or a Fragment.
    #
    # @param [::CodeList|Integer] codelist_id Either the CodeList or CodeList ID for exporting
    # @return [Nokogiri::XML::Node] New XML node
    def V3_2(codelist_id)
      if codelist_id.is_a? ::CodeList
        codelist = codelist_id
      else
        codelist = ::CodeList.find codelist_id
      end

      cl = Nokogiri::XML::Node.new 'l:CodeList', @doc
      urn = create_urn_node codelist
      cl.add_child urn
      l = Nokogiri::XML::Node.new 'r:Label', @doc
      l.add_child "<r:Content xml:lang=\"en-GB\">%{label}</r:Content>" % {
          label: CGI::escapeHTML(codelist.label.to_s)
      }
      urn.add_next_sibling l
      inner_prev = l
      codelist.codes.find_each do |code|
        co = Nokogiri::XML::Node.new 'l:Code', @doc
        inner_prev.add_next_sibling co
        c_urn = create_urn_node code
        co.add_child c_urn
        c_ref = create_reference_string 'r:CategoryReference', code.category
        c_urn.add_next_sibling c_ref
        c_ref.add_next_sibling "<r:Value>%{val}</r:Value>" % {val: code.value}
        inner_prev = co
      end

      cl
    end
  end
end
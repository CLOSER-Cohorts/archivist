module Exporters::XML::DDI
  class CodeList < DdiExporterBase
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
module Exporters::XML::DDI
  # DDI 3.2 XML Exporter for {::Category}
  #
  # {::Category} is a direct alias of DDI 3.2 Category.
  #
  # === Example
  #   doc = Nokogiri::XML::Document.new
  #   cat = Category.first
  #   exporter = Exporters::XML::DDI::Category.new doc
  #   xml_node = exporter.V3_2(cat)
  #
  # @see ::Category
  class Category < DdiExporterBase
    # Exports the {::Category} in DDI 3.2
    #
    # Create a single XML node as an export of a single {::Category}.
    # In order to be valid DDI, this node then needs to be wrapped
    # either in a CategoryScheme or a Fragment.
    #
    # @param [::Category|Integer] category_id Either the Category or Category ID for exporting
    # @return [Nokogiri::XML::Node] New XML node
    def V3_2(category_id)
      if category_id.is_a? ::Category
        cat = category_id
      else
        cat = ::Category.find category_id
      end

      c = Nokogiri::XML::Node.new 'l:Category', @doc
      urn = create_urn_node cat
      c.add_child urn
      cn = Nokogiri::XML::Node.new 'l:CategoryName', @doc
      cn.add_child "<r:String xml:lang=\"en-GB\">%d</r:String>" % cat.id
      urn.add_next_sibling cn
      l = Nokogiri::XML::Node.new 'r:Label', @doc
      con = Nokogiri::XML::Node.new 'r:Content', @doc
      con['xml:lang'] = 'en-GB'
      con.content = CGI::escapeHTML(cat.label.to_s)
      l.add_child con
      cn.add_next_sibling l

      c
    end
  end
end
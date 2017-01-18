module Exporters::XML::DDI
  class Category < DdiExporterBase
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
      con.content = CGI::escapeHTML(cat.label)
      l.add_child con
      cn.add_next_sibling l

      c
    end
  end
end
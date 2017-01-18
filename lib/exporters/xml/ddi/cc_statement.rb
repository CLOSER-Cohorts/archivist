module Exporters::XML::DDI
  class CcStatement < DdiExporterBase
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
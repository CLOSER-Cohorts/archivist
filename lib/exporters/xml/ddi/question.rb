module Exporters::XML::DDI
  class Question < DdiExporterBase
    def V3_2(id)
      if id.is_a? @klass
        obj = id
      else
        obj = @klass.find id
      end

      q = Nokogiri::XML::Node.new @klass.tag, @doc
      urn = create_urn_node obj
      q.add_child urn
      uap = Nokogiri::XML::Node.new 'r:UserAttributePair', @doc
      uap.add_child "<r:AttributeKey>extension:Label</r:AttributeKey><r:AttributeValue>{\"en-GB\":\"%{label}\"}</r:AttributeValue>" %
                        {label: Util::question_label(obj.label)}
      urn.add_next_sibling uap
      qn = Nokogiri::XML::Node.new @klass.tag + 'Name', @doc
      qn.add_child "<r:String xml:lang=\"en-GB\">%{label}</r:String>" %
                        {label: obj.label}
      uap.add_next_sibling qn
      qt = Nokogiri::XML::Node.new 'd:QuestionText', @doc
      qt['audienceLanguage'] = 'en-GB'
      qt.add_child '<d:LiteralText><d:Text>%{text}</d:Text></d:LiteralText>' %
                       {text: CGI::escapeHTML(obj.literal)}
      qn.add_next_sibling qt

      yield obj, q

      return q
    end
  end
end
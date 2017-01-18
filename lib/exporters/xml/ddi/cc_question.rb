module Exporters::XML::DDI
  class CcQuestion < DdiExporterBase
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
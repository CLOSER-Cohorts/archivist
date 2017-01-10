module Exporters::XML::DDI
  class CcSequence < DdiExporterBase
    def V3_2(seq_id)
      if seq_id.is_a? ::CcSequence
        cc = seq_id
      else
        cc = ::CcSequence.find seq_id
      end

      seq = Nokogiri::XML::Node.new 'd:Sequence', @doc
      urn = create_urn_node cc
      seq.add_child urn
      cn = Nokogiri::XML::Node.new 'd:ConstructName', @doc
      s = Nokogiri::XML::Node.new 'r:String', @doc
      s['xml:lang'] = 'en-GB'
      s.content = cc.label
      cn.add_child s
      seq.add_child cn
      l = Nokogiri::XML::Node.new 'r:Label', @doc
      c = Nokogiri::XML::Node.new 'r:Content', @doc
      c['xml:lang'] = 'en-GB'
      c.content = cc.label
      l.add_child c
      cn.add_next_sibling l
      inner_prev = l
      cc.children.each do |child|
        ccf = create_reference_string 'd:ControlConstructReference', child.construct
        inner_prev.add_next_sibling ccf
        inner_prev = ccf
      end

      seq
    end
  end
end
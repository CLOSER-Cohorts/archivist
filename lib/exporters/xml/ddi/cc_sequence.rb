module Exporters::XML::DDI
  # DDI 3.2 XML Exporter for {::CcSequence}
  #
  # {::CcSequence} is a direct alias of DDI 3.2 Sequence.
  #
  # === Example
  #   doc = Nokogiri::XML::Document.new
  #   seq = CcSequence.first
  #   exporter = Exporters::XML::DDI::CcSequence.new doc
  #   xml_node = exporter.V3_2(seq)
  #
  # @see ::CcSequence
  class CcSequence < DdiExporterBase
    # Exports the {::CcSequence} in DDI 3.2
    #
    # Create a single XML node as an export of a single {::CcSequence}.
    # In order to be valid DDI, this node then needs to be wrapped
    # either in a ControlConstructScheme or a Fragment.
    #
    # @param [::CcSequence|Integer] seq_id Either the CcSequence or CcSequence ID for exporting
    # @return [Nokogiri::XML::Node] New XML node
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
        ccf = create_reference_string 'd:ControlConstructReference', child
        inner_prev.add_next_sibling ccf
        inner_prev = ccf
      end

      seq
    end
  end
end
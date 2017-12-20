module Exporters::XML::DDI
  # DDI 3.2 XML Exporter for {::CcLoop}
  #
  # {::CcLoop} is a direct alias of DDI 3.2 Loop.
  #
  # === Example
  #   doc = Nokogiri::XML::Document.new
  #   loop = CcLoop.first
  #   exporter = Exporters::XML::DDI::CcLoop.new doc
  #   xml_node = exporter.V3_2(loop)
  #
  # @see ::CcLoop
  class CcLoop < DdiExporterBase
    # Exports the {::CcLoop} in DDI 3.2
    #
    # Create a single XML node as an export of a single {::CcLoop}.
    # In order to be valid DDI, this node then needs to be wrapped
    # either in a ControlConstructScheme or a Fragment.
    #
    # @param [::CcLoop|Integer] lp_id Either the CcLoop or CcLoop ID for exporting
    # @return [Nokogiri::XML::Node] New XML node
    def V3_2(lp_id)
      cc = lp_id.is_a?(::CcLoop) ? lp_id : ::CcLoop.find(lp_id)

      lp = Nokogiri::XML::Node.new 'd:Loop', @doc
      urn = create_urn_node cc
      lp.add_child urn
      cn = Nokogiri::XML::Node.new 'd:ConstructName', @doc
      s = Nokogiri::XML::Node.new 'r:String', @doc
      s['xml:lang'] = 'en-GB'
      s.content = cc.label
      cn.add_child s
      lp.add_child cn
      lp.add_child '<d:InitialValue><r:Command><r:ProgramLanguage>pseudo-code</r:ProgramLanguage>' +
                       '<r:CommandContent>%{command}</r:CommandContent></r:Command></d:InitialValue>' % {
                           command: CGI::escapeHTML(cc.loop_var.to_s) + ' = ' + cc.start_val
                       }

      lp.add_child build_loop_while(cc)
      lp.add_child build_loop_sequence_reference(cc)

      ns = Nokogiri::XML::NodeSet.new @doc
      ns.push lp
      ns.push build_loop_sequence(cc.children)
      ns
    end

    private # Private methods
    def build_loop_while(cc)
      command = ''
      unless cc.end_val.nil?
        command += cc.loop_var + ' < ' + cc.end_val
      end
      unless cc.end_val.nil? || cc.loop_while.nil?
        command += ' && '
      end
      unless cc.loop_while.nil?
        command += cc.loop_while
      end

      return '<d:LoopWhile><r:Command><r:ProgramLanguage>pseudo-code</r:ProgramLanguage>' +
                       '<r:CommandContent>%{command}</r:CommandContent></r:Command></d:LoopWhile>' % {
                           command: CGI::escapeHTML(command.to_s)
                       }
    end

    def build_loop_sequence_reference(cc)
      ('<d:ControlConstructReference><r:URN>urn:ddi:%{agency}:%{prefix}-selp-%{id}:1.0.0</r:URN>' +
          '<r:TypeOfObject>Sequence</r:TypeOfObject></d:ControlConstructReference>') % {
          agency: cc.instrument.agency,
          prefix: cc.instrument.prefix,
          id: '%06d' % cc.id
      }
    end

    def build_loop_sequence(children)
      selp = Nokogiri::XML::Node.new 'd:Sequence', @doc
      selp.add_child create_urn_node(cc, 'selp')
      selp_cn = Nokogiri::XML::Node.new 'd:ConstructName', @doc
      selp_s = Nokogiri::XML::Node.new 'r:String', @doc
      selp_s['xml:lang'] = 'en-GB'
      selp_s.content = 'loop_seq_' + cc.label
      selp_cn.add_child selp_s
      selp.add_child selp_cn

      selp_l = Nokogiri::XML::Node.new 'r:Label', @doc
      selp_c = Nokogiri::XML::Node.new 'r:Content', @doc
      selp_c['xml:lang'] = 'en-GB'
      selp_c.content = 'loop_seq_' + cc.label
      selp_l.add_child selp_c
      selp_cn.add_next_sibling selp_l

      selp_inner_prev = selp_l
      children.each do |child|
        ccf = create_reference_string 'd:ControlConstructReference', child
        selp_inner_prev.add_next_sibling ccf
        selp_inner_prev = ccf
      end
      return selp
    end
  end
end

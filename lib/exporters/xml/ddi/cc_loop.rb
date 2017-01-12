module Exporters::XML::DDI
  class CcLoop < DdiExporterBase
    def V3_2(lp_id)
      if lp_id.is_a? ::CcLoop
        cc = lp_id
      else
        cc = ::CcLoop.find lp_id
      end

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
                           command: CGI::escapeHTML(cc.loop_var) + ' = ' + cc.start_val
                       }
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

      lp.add_child '<d:LoopWhile><r:Command><r:ProgramLanguage>pseudo-code</r:ProgramLanguage>' +
                       '<r:CommandContent>%{command}</r:CommandContent></r:Command></d:LoopWhile>' % {
                           command: CGI::escapeHTML(command)
                       }
      lp.add_child ('<d:ControlConstructReference><r:URN>urn:ddi:%{agency}:%{prefix}-selp-%{id}:1.0.0</r:URN> ' +
          '<r:TypeOfObject>Sequence</r:TypeOfObject></d:ControlConstructReference>') % {
            agency: cc.instrument.agency,
            prefix: cc.instrument.prefix,
            id: '%06d' % cc.id
        }

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
      cc.children.each do |child|
        ccf = create_reference_string 'd:ControlConstructReference', child.construct
        selp_inner_prev.add_next_sibling ccf
        selp_inner_prev = ccf
      end

      ns = Nokogiri::XML::NodeSet.new @doc
      ns.push lp
      ns.push selp
      ns
    end
  end
end
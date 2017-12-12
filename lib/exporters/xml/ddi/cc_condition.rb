module Exporters::XML::DDI
  # DDI 3.2 XML Exporter for {::CcCondition}
  #
  # {::CcCondition} is a direct alias of DDI 3.2 IfThenElse.
  #
  # === Example
  #   doc = Nokogiri::XML::Document.new
  #   con = CcCondition.first
  #   exporter = Exporters::XML::DDI::CcCondition.new doc
  #   xml_node = exporter.V3_2(con)
  #
  # @see ::CcCondition
  class CcCondition < DdiExporterBase
    # Exports the {::CcCondition} in DDI 3.2
    #
    # Create a single XML node as an export of a single {::CcCondition}.
    # In order to be valid DDI, this node then needs to be wrapped
    # either in a ControlConstructScheme or a Fragment.
    #
    # @param [::CcCondition|Integer] con_id Either the CcCondition or CcCondition ID for exporting
    # @return [Nokogiri::XML::Node] New XML node
    def V3_2(con_id)
      if con_id.is_a? ::CcCondition
        cc = con_id
      else
        cc = ::CcCondition.find con_id
      end

      con = Nokogiri::XML::Node.new 'd:IfThenElse', @doc
      urn = create_urn_node cc
      con.add_child urn

      cn = Nokogiri::XML::Node.new 'd:ConstructName', @doc
      s = Nokogiri::XML::Node.new 'r:String', @doc
      s['xml:lang'] = 'en-GB'
      s.content = cc.label
      cn.add_child s
      urn.add_next_sibling cn

      ic = Nokogiri::XML::Node.new 'd:IfCondition', @doc
      d = Nokogiri::XML::Node.new 'r:Description', @doc
      c = Nokogiri::XML::Node.new 'r:Content', @doc
      c['xml:lang'] = 'en-GB'
      c.content = cc.literal
      d.add_child c
      ic.add_child d
      cn.add_next_sibling ic

      com = Nokogiri::XML::Node.new 'r:Command', @doc
      com.add_child '<r:ProgramLanguage>pseudo-code</r:ProgramLanguage>'
      comc = Nokogiri::XML::Node.new 'r:CommandContent', @doc
      comc.content = cc.logic
      com.add_child comc
      ic.add_child com

      process_condition_branch = lambda do |branch, prefix, construct_ref|
        tcr = Nokogiri::XML::Node.new 'd:' + construct_ref.humanize + 'ConstructReference', @doc
        tcr.add_child create_urn_node(cc, prefix)
        tcr.add_child '<r:TypeOfObject>Sequence</r:TypeOfObject>'

        seth = Nokogiri::XML::Node.new 'd:Sequence', @doc
        seth.add_child create_urn_node(cc, prefix)
        seth_cn = Nokogiri::XML::Node.new 'd:ConstructName', @doc
        seth_s = Nokogiri::XML::Node.new 'r:String', @doc
        seth_s['xml:lang'] = 'en-GB'
        seth_s.content = construct_ref + '_seq_' + cc.label
        seth_cn.add_child seth_s
        seth.add_child seth_cn

        seth_l = Nokogiri::XML::Node.new 'r:Label', @doc
        seth_c = Nokogiri::XML::Node.new 'r:Content', @doc
        seth_c['xml:lang'] = 'en-GB'
        seth_c.content = construct_ref + '_seq_' + cc.label
        seth_l.add_child seth_c
        seth_cn.add_next_sibling seth_l

        seth_inner_prev = seth_l
        cc.children.where(branch: branch).each do |child|
          ccf = create_reference_string 'd:ControlConstructReference', child
          seth_inner_prev.add_next_sibling ccf
          seth_inner_prev = ccf
        end
        return tcr, seth
      end

      ns = Nokogiri::XML::NodeSet.new @doc
      ns.push con

      if cc.children.branch(0).count > 0
        tcr, seth = process_condition_branch.call(0, 'seth', 'then')
        con.add_child tcr
        ns.push seth
      end

      if cc.children.branch(1).count > 0
        fcr, seel = process_condition_branch.call(1, 'seel', 'else')
        con.add_child fcr
        ns.push seel
      end

      ns
    end
  end
end
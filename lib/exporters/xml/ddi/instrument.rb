module Exporters::XML::DDI
  class URNGenerator

  end

  class Instrument
    def initialize
      @doc = Nokogiri::XML '<ddi:DDIInstance></ddi:DDIInstance>'
    end

    def add_root_attributes
      @datetimestring = Time.now.strftime '%Y-%m-%dT%H:%M:%S%:z'
      @doc.root['versionDate'] = @datetimestring
      @doc.root['xmlns:d'] = 'ddi:datacollection:3_2'
      @doc.root['xmlns:ddi'] = 'ddi:instance:3_2'
      @doc.root['xmlns:g'] = 'ddi:group:3_2'
      @doc.root['xmlns:l'] = 'ddi:logicalproduct:3_2'
      @doc.root['xmlns:r'] = 'ddi:reusable:3_2'
    end

    def run(instrument)
      export_instrument instrument

      build_rp
      build_iis
      build_cs
      build_cls
      build_qis
      build_qgs
      build_is
      build_ccs

      FileUtils.mkdir_p Rails.root.join('tmp', 'exports')
      filename = Rails.root.join(
          'tmp',
          'exports',
          instrument.prefix + '.xml'
      )
      f = File.new filename, 'w'
      f.write(@doc.to_xml &:no_empty_tags)
      f.close
      filename
    end

    def export_instrument(instrument)
      @instrument = instrument
      @urn_prefix = 'urn:ddi:%{agency}:%{prefix}' %
          {agency: @instrument.agency, prefix: @instrument.prefix}
      urn = Nokogiri::XML::Node.new 'r:URN', @doc
      urn.content = @urn_prefix + '-ddi-000001:1.0.0'
      @doc.root.add_child urn

      cit = Nokogiri::XML::Node.new 'r:Citation', @doc
      urn.add_next_sibling cit
      cit.add_child "<r:Title><r:String xml:lang=\"en-GB\">%{prefix} instance 01</r:String></r:Title>" %
          {prefix: @instrument.prefix}
      cit.add_child '<r:SubTitle><r:String xml:lang="en-GB">Metadata documented by CLOSER using Archivist.</r:String></r:SubTitle>'

      @rp = Nokogiri::XML::Node.new 'g:ResourcePackage', @doc
      @rp['versionDate'] = @datetimestring
      cit.add_next_sibling @rp
    end

    def build_rp
      urn = Nokogiri::XML::Node.new 'r:URN', @doc
      urn.content = @urn_prefix + '-rp-000001:1.0.0'
      @rp.add_child urn
      cit = Nokogiri::XML::Node.new 'r:Citation', @doc
      cit.add_child "<r:Title><r:String xml:lang=\"en-GB\">%{prefix} resource package 01</r:String></r:Title>" %
          {prefix: @instrument.prefix}
      urn.add_next_sibling cit
      pur = Nokogiri::XML::Node.new 'r:Purpose', @doc
      pur.add_child '<r:Content xml:lang="en-GB">not specified</r:Content>'
      cit.add_next_sibling pur

      @iis = Nokogiri::XML::Node.new 'd:InterviewerInstructionScheme', @doc
      @iis['versionDate'] = @datetimestring
      pur.add_next_sibling @iis

      @ccs = Nokogiri::XML::Node.new 'd:ControlConstructScheme', @doc
      @iis.add_next_sibling @ccs

      @qis = Nokogiri::XML::Node.new 'd:QuestionScheme', @doc
      @qis['versionDate'] = @datetimestring
      @ccs.add_next_sibling @qis

      @qgs = Nokogiri::XML::Node.new 'd:QuestionScheme', @doc
      @qgs['versionDate'] = @datetimestring
      @qis.add_next_sibling @qgs

      @cs = Nokogiri::XML::Node.new 'l:CategoryScheme', @doc
      @cs['versionDate'] = @datetimestring
      @qgs.add_next_sibling @cs

      @cls = Nokogiri::XML::Node.new 'l:CodeListScheme', @doc
      @cls['versionDate'] = @datetimestring
      @cs.add_next_sibling @cls

      @is = Nokogiri::XML::Node.new 'd:InstrumentScheme', @doc
      @cls.add_next_sibling @is
    end

    def build_iis
      urn = Nokogiri::XML::Node.new 'r:URN', @doc
      urn.content = @urn_prefix + '-iis-000001:1.0.0'
      @iis.add_child urn
      iisn = Nokogiri::XML::Node.new 'd:InterviewerInstructionSchemeName', @doc
      iisn.add_child "<r:String xml:lang=\"en-GB\">%{prefix}_is01</r:String>" %
          {prefix: @instrument.prefix}
      urn.add_next_sibling iisn
      prev = iisn
      @instrument.instructions.find_each do |instr|
        i = Nokogiri::XML::Node.new 'd:Instruction', @doc
        prev.add_next_sibling i
        urn = create_urn_node instr
        i.add_child urn
        urn.add_next_sibling "<d:InstructionText audienceLanguage=\"en-GB\"><d:LiteralText><d:Text>%{literal}</d:Text></d:LiteralText></d:InstructionText>" %
            {literal: CGI::escapeHTML(instr.text)}
        prev = i
      end
    end

    def build_cs
      urn = Nokogiri::XML::Node.new 'r:URN', @doc
      urn.content = @urn_prefix + '-cas-000001:1.0.0'
      @cs.add_child urn
      csn = Nokogiri::XML::Node.new 'l:CategorySchemeName', @doc
      csn.add_child "<r:String xml:lang=\"en-GB\">%{prefix}_cs01</r:String>" %
                         {prefix: @instrument.prefix}
      urn.add_next_sibling csn
      prev = csn
      @instrument.categories.find_each do |cat|
        c = Nokogiri::XML::Node.new 'l:Category', @doc
        prev.add_next_sibling c
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

        prev = c
      end
    end

    def build_cls
      urn = Nokogiri::XML::Node.new 'r:URN', @doc
      urn.content = @urn_prefix + '-cos-000001:1.0.0'
      @cls.add_child urn
      clsn = Nokogiri::XML::Node.new 'l:CodeListSchemeName', @doc
      clsn.add_child "<r:String xml:lang=\"en-GB\">%{prefix}_cos01</r:String>" %
                        {prefix: @instrument.prefix}
      urn.add_next_sibling clsn
      prev = clsn
      @instrument.code_lists.find_each do |codelist|
        cl = Nokogiri::XML::Node.new 'l:CodeList', @doc
        prev.add_next_sibling cl
        urn = create_urn_node codelist
        cl.add_child urn
        l = Nokogiri::XML::Node.new 'r:Label', @doc
        l.add_child "<r:Content xml:lang=\"en-GB\">%{label}</r:Content>" % {
            label: CGI::escapeHTML(codelist.label)
        }
        urn.add_next_sibling l
        inner_prev = l
        codelist.codes.find_each do |code|
          co = Nokogiri::XML::Node.new 'l:Code', @doc
          inner_prev.add_next_sibling co
          c_urn = create_urn_node code
          co.add_child c_urn
          c_ref = create_reference_string 'r:CategoryReference', code.category
          c_urn.add_next_sibling c_ref
          c_ref.add_next_sibling "<r:Value>%{val}</r:Value>" % {val: code.value}
          inner_prev = co
        end

        prev = cl
      end
    end

    def build_qis
      urn = Nokogiri::XML::Node.new 'r:URN', @doc
      urn.content = @urn_prefix + '-qs-000001:1.0.0'
      @qis.add_child urn
      qisn = Nokogiri::XML::Node.new 'd:QuestionSchemeName', @doc
      qisn.add_child "<r:String xml:lang=\"en-GB\">%{prefix}_qs01</r:String>" %
                        {prefix: @instrument.prefix}
      urn.add_next_sibling qisn
      prev = qisn

      qi_exporter = Exporters::XML::DDI::QuestionItem.new @doc
      @instrument.question_items.find_each do |qitem|
        qi = qi_exporter.V3_2 qitem
        prev.add_next_sibling qi
        prev = qi
      end
    end

    def build_qgs
      urn = Nokogiri::XML::Node.new 'r:URN', @doc
      urn.content = @urn_prefix + '-qgs-000002:1.0.0'
      @qgs.add_child urn
      qgsn = Nokogiri::XML::Node.new 'd:QuestionSchemeName', @doc
      qgsn.add_child "<r:String xml:lang=\"en-GB\">%{prefix}_qgs01</r:String>" %
                         {prefix: @instrument.prefix}
      urn.add_next_sibling qgsn
      prev = qgsn

      qg_exporter = Exporters::XML::DDI::QuestionGrid.new @doc
      @instrument.question_grids.find_each do |qgrid|
        qg = qg_exporter.V3_2 qgrid
        prev.add_next_sibling qg
        prev = qg
      end
    end

    def build_ccs
      urn = Nokogiri::XML::Node.new 'r:URN', @doc
      urn.content = @urn_prefix + '-ccs-000001:1.0.0'
      @ccs.add_child urn
      ccsn = Nokogiri::XML::Node.new 'd:ControlConstructSchemeName', @doc
      ccsn.add_child "<r:String xml:lang=\"en-GB\">%{prefix}_ccs01</r:String>" %
                        {prefix: @instrument.prefix}
      urn.add_next_sibling ccsn
      prev = ccsn
      @instrument.ccs_in_ddi_order.each do |cc|
        urn = create_urn_node cc
        case cc
          when CcCondition
            con = Nokogiri::XML::Node.new 'd:IfThenElse', @doc
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

            prev.add_next_sibling con
            prev = con

            process_condition_branch = lambda do |branch, prefix, construct_ref|
              tcr = Nokogiri::XML::Node.new 'd:' + construct_ref.humanize + 'ConstructReference', @doc
              tcr.add_child '<r:URN>' + [@urn_prefix, prefix, '%06d:1.0.0' % cc.id].join('-') + '</r:URN>'
              tcr.add_child '<r:TypeOfObject>Sequence</r:TypeOfObject>'

              seth = Nokogiri::XML::Node.new 'd:Sequence', @doc
              seth.add_child '<r:URN>' + [@urn_prefix, prefix, '%06d:1.0.0' % cc.id].join('-') + '</r:URN>'
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
                ccf = create_reference_string 'd:ControlConstructReference', child.construct
                seth_inner_prev.add_next_sibling ccf
                seth_inner_prev = ccf
              end
              return tcr, seth
            end

            if cc.children.where(branch: 0).count > 0
              tcr, seth = process_condition_branch.call(0, 'seth', 'then')
              prev.add_child tcr
            end

            if cc.children.where(branch: 1).count > 0
              fcr, seel = process_condition_branch.call(1, 'seel', 'else')
              prev.add_child fcr
            end

            unless seth.nil?
              prev.add_next_sibling seth
              prev = seth
            end

            unless seel.nil?
              prev.add_next_sibling seel
              prev = seel
            end

          when CcQuestion
            qc = Nokogiri::XML::Node.new 'd:QuestionConstruct', @doc
            qc.add_child urn

            cn = Nokogiri::XML::Node.new 'd:ConstructName', @doc
            s = Nokogiri::XML::Node.new 'r:String', @doc
            s['xml:lang'] = 'en-GB'
            s.content = cc.label
            cn.add_child s
            urn.add_next_sibling cn

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
            prev.add_next_sibling qc
            prev = qc

          when CcStatement
            st = Nokogiri::XML::Node.new 'd:StatementItem', @doc
            st.add_child urn

            cn = Nokogiri::XML::Node.new 'd:ConstructName', @doc
            s = Nokogiri::XML::Node.new 'r:String', @doc
            s['xml:lang'] = 'en-GB'
            s.content = cc.label
            cn.add_child s
            urn.add_next_sibling cn

            dt = Nokogiri::XML::Node.new 'd:DisplayText', @doc
            dt['audienceLanguage'] = 'en-GB'
            lt = Nokogiri::XML::Node.new 'd:LiteralText', @doc
            t = Nokogiri::XML::Node.new 'd:Text', @doc
            t.content = cc.literal
            lt.add_child t
            dt.add_child lt
            cn.add_next_sibling dt
            prev.add_next_sibling st
            prev = st

          when CcSequence
            seq = Nokogiri::XML::Node.new 'd:Sequence', @doc
            seq.add_child urn

            cn = Nokogiri::XML::Node.new 'd:ConstructName', @doc
            s = Nokogiri::XML::Node.new 'r:String', @doc
            s['xml:lang'] = 'en-GB'
            s.content = cc.label
            cn.add_child s
            urn.add_next_sibling cn
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
            prev.add_next_sibling seq
            prev = seq

          when CcLoop
            lp = Nokogiri::XML::Node.new 'd:Loop', @doc
            lp.add_child urn

            cn = Nokogiri::XML::Node.new 'd:ConstructName', @doc
            s = Nokogiri::XML::Node.new 'r:String', @doc
            s['xml:lang'] = 'en-GB'
            s.content = cc.label
            cn.add_child s
            urn.add_next_sibling cn
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
            lp.add_child '<d:ControlConstructReference><r:URN>urn:ddi:uk.alspac:alspac_00_msdhs-selp-%06d:1.0.0</r:URN><r:TypeOfObject>Sequence</r:TypeOfObject></d:ControlConstructReference>' % cc.id

            prev.add_next_sibling lp
            prev = lp

            selp = Nokogiri::XML::Node.new 'd:Sequence', @doc
            selp.add_child '<r:URN>' + [@urn_prefix, 'selp', '%06d:1.0.0' % cc.id].join('-') + '</r:URN>'
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
            prev.add_next_sibling selp
            prev = selp
        end
      end
    end

    def build_is
      urn = Nokogiri::XML::Node.new 'r:URN', @doc
      urn.content = @urn_prefix + '-ins-000001:1.0.0'
      @is.add_child urn
      isn = Nokogiri::XML::Node.new 'd:InstrumentSchemeName', @doc
      isn.add_child "<r:String xml:lang=\"en-GB\">%{prefix}_is01</r:String>" %
                        {prefix: @instrument.prefix}
      urn.add_next_sibling isn
      i = Nokogiri::XML::Node.new 'd:Instrument', @doc
      i.add_child create_urn_node @instrument
      i.add_child "<d:InstrumentName><r:String xml:lang=\"en-GB\">%{title}</r:String></d:InstrumentName>" %
          {title: CGI::escapeHTML(@instrument.label)}
      i.add_child create_reference_string 'd:ControlConstructReference', @instrument.top_sequence
      isn.add_next_sibling i
    end

    def doc
      @doc
    end

    private
    def create_urn_node(obj)
      urn = Nokogiri::XML::Node.new 'r:URN', @doc
      urn.content = obj.urn @urn_prefix
      urn
    end

    def create_reference_string(node_name, obj)
      ref = Nokogiri::XML::Node.new node_name, @doc
      ref.add_child '<r:URN>%{urn}</r:URN><r:TypeOfObject>%{type}</r:TypeOfObject>' %
          {urn: obj.urn(@urn_prefix), type: obj.class::TYPE}
      ref
    end
  end
end
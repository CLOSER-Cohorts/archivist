module XML::DDI
  class URNGenerator

  end

  class Exporter
    def initialize
      @doc = Nokogiri::XML '<ddi:DDIInstance></ddi:DDIInstance>'
      @urns = {}
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
      f = File.new filename, "w"
      f.write(@doc.to_xml &:no_empty_tags)
      f.close
      filename
    end

    def export_instrument(instrument)
      @instrument = instrument
      @urn_prefix = "urn:ddi:%{agency}:%{prefix}-" %
          {agency: @instrument.agency, prefix: @instrument.prefix}
      urn = Nokogiri::XML::Node.new 'r:URN', @doc
      urn.content = @urn_prefix + 'ddi-000001:1.0.0'
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
      urn.content = @urn_prefix + 'rp-000001:1.0.0'
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
      urn.content = @urn_prefix + 'iis-000001:1.0.0'
      @iis.add_child urn
      iisn = Nokogiri::XML::Node.new 'd:InterviewerInstructionSchemeName', @doc
      iisn.add_child "<r:String xml:lang=\"en-GB\">%{prefix}_is01</r:String>" %
          {prefix: @instrument.prefix}
      urn.add_next_sibling iisn
      prev = iisn
      counter = 0
      @urns[:instructions] = {}
      @instrument.instructions.find_each do |instr|
        counter += 1
        i = Nokogiri::XML::Node.new 'd:Instruction', @doc
        prev.add_next_sibling i
        urn = Nokogiri::XML::Node.new 'r:URN', @doc
        @urns[:instructions][instr.id] = @urn_prefix + "ii-%06d:1.0.0" % counter
        urn.content = @urns[:instructions][instr.id]
        i.add_child urn
        urn.add_next_sibling "<d:InstructionText audienceLanguage=\"en-GB\"><d:LiteralText><d:Text>%{literal}</d:Text></d:LiteralText></d:InstructionText>" %
            {literal: instr.text}
        prev = i
      end
    end

    def build_cs
      urn = Nokogiri::XML::Node.new 'r:URN', @doc
      urn.content = @urn_prefix + 'cas-000001:1.0.0'
      @cs.add_child urn
      csn = Nokogiri::XML::Node.new 'l:CategorySchemeName', @doc
      csn.add_child "<r:String xml:lang=\"en-GB\">%{prefix}_cs01</r:String>" %
                         {prefix: @instrument.prefix}
      urn.add_next_sibling csn
      prev = csn
      counter = 0
      @urns[:categories] = {}
      @instrument.categories.find_each do |cat|
        counter += 1
        c = Nokogiri::XML::Node.new 'l:Category', @doc
        prev.add_next_sibling c
        urn = Nokogiri::XML::Node.new 'r:URN', @doc
        @urns[:categories][cat.id] = @urn_prefix + "ca-%06d:1.0.0" % counter
        urn.content = @urns[:categories][cat.id]
        c.add_child urn
        cn = Nokogiri::XML::Node.new 'l:CategoryName', @doc
        cn.add_child "<r:String xml:lang=\"en-GB\">%d</r:String>" % counter
        urn.add_next_sibling cn
        l = Nokogiri::XML::Node.new 'r:Label', @doc
        con = Nokogiri::XML::Node.new 'r:Content', @doc
        con['xml:lang'] = 'en-GB'
        con.content = cat.label
        l.add_child con
        cn.add_next_sibling l

        prev = c
      end
    end

    def build_cls
      urn = Nokogiri::XML::Node.new 'r:URN', @doc
      urn.content = @urn_prefix + 'cos-000001:1.0.0'
      @cls.add_child urn
      clsn = Nokogiri::XML::Node.new 'l:CodeListSchemeName', @doc
      clsn.add_child "<r:String xml:lang=\"en-GB\">%{prefix}_cos01</r:String>" %
                        {prefix: @instrument.prefix}
      urn.add_next_sibling clsn
      prev = clsn
      counter = 0
      @urns[:codes] = {}
      @instrument.code_lists.find_each do |codelist|
        counter += 1
        cl = Nokogiri::XML::Node.new 'l:CodeList', @doc
        prev.add_next_sibling cl
        urn = Nokogiri::XML::Node.new 'r:URN', @doc
        @urns[:codes][codelist.id] = @urn_prefix + "cl-%06d:1.0.0" % counter
        urn.content = @urns[:codes][codelist.id]
        cl.add_child urn
        l = Nokogiri::XML::Node.new 'r:Label', @doc
        l.add_child "<r:Content xml:lang=\"en-GB\">%{label}</r:Content>" % {label: codelist.label}
        urn.add_next_sibling l
        inner_prev = l
        codelist.codes.find_each do |code|
          co = Nokogiri::XML::Node.new 'l:Code', @doc
          inner_prev.add_next_sibling co
          c_urn = Nokogiri::XML::Node.new 'r:URN', @doc
          c_urn.content = @urn_prefix + "co-%06d:1.0.0" % code.id
          co.add_child c_urn
          c_ref = Nokogiri::XML::Node.new 'r:CategoryReference', @doc
          c_ref.add_child "<r:URN>%{urn}</r:URN><r:TypeOfObject>Category</r:TypeOfObject>" %
              {urn: @urns[:categories][code.category_id]}
          c_urn.add_next_sibling c_ref
          c_ref.add_next_sibling "<r:Value>%{val}</r:Value>" % {val: code.value}
          inner_prev = co
        end

        prev = cl
      end
    end

    def build_qis
      urn = Nokogiri::XML::Node.new 'r:URN', @doc
      urn.content = @urn_prefix + 'qs-000001:1.0.0'
      @qis.add_child urn
      qisn = Nokogiri::XML::Node.new 'd:QuestionSchemeName', @doc
      qisn.add_child "<r:String xml:lang=\"en-GB\">%{prefix}_qs01</r:String>" %
                        {prefix: @instrument.prefix}
      urn.add_next_sibling qisn
      prev = qisn
      counter = 0
      @urns[QuestionItem.name] = {}
      @instrument.question_items.find_each do |qitem|
        counter += 1
        qi = Nokogiri::XML::Node.new 'd:QuestionItem', @doc
        prev.add_next_sibling qi
        urn = Nokogiri::XML::Node.new 'r:URN', @doc
        @urns[QuestionItem.name][qitem.id] = @urn_prefix + "qi-%06d:1.0.0" % counter
        urn.content = @urns[QuestionItem.name][qitem.id]
        qi.add_child urn
        uap = Nokogiri::XML::Node.new 'r:UserAttributePair', @doc
        uap.add_child "<r:AttributeKey>extension:Label</r:AttributeKey><r:AttributeValue>{\"en-GB\":\"%{label}\"}</r:AttributeValue>" %
        {label: Util::question_label(qitem.label)}
        urn.add_next_sibling uap
        qin = Nokogiri::XML::Node.new 'd:QuestionItemName', @doc
        qin.add_child "<r:String xml:lang=\"en-GB\">%{label}</r:String>" %
            {label: qitem.label}
        uap.add_next_sibling qin
        qt = Nokogiri::XML::Node.new 'd:QuestionText', @doc
        qt['audienceLanguage'] = 'en-GB'
        qt.add_child "<d:LiteralText><d:Text>%{text}</d:Text></d:LiteralText>" %
             {text: qitem.literal}
        qin.add_next_sibling qt

        inner_prev = qt

        build_response_domain = lambda do |rd|
          case rd
            when ResponseDomainCode
              cd = Nokogiri::XML::Node.new 'd:CodeDomain', @doc
              cd.add_child "<r:CodeListReference><r:URN>%{urn}</r:URN><r:TypeOfObject>CodeList</r:TypeOfObject></r:CodeListReference>" %
                               {urn: @urns[:codes][rd.code_list_id]}

              return cd
            when ResponseDomainDatetime
              dd = Nokogiri::XML::Node.new 'd:DateTimeDomain', @doc
              dd.add_child "<r:DateFieldFormat>%{format}</r:DateFieldFormat><r:DateTypeCode>%{type}</r:DateTypeCode><r:Label><r:Content xml:lang=\"en-GB\">%{label}</r:Content></r:Label>" %
                               {label: rd.label, type: rd.datetime_type, format: rd.format || ''}

              return dd
            when ResponseDomainNumeric
              nd = Nokogiri::XML::Node.new 'd:NumericDomain', @doc
              nd.add_child "<r:NumberRange>%{range}</r:NumberRange><r:NumericTypeCode>%{type}</r:NumericTypeCode><r:Label><r:Content xml:lang=\"en-GB\">%{label}</r:Content></r:Label>" %
                               {label: rd.label, type: rd.numeric_type, range: (if rd.min then "<r:Low>%d</r:Low>" % rd.min else '' end) + (if rd.max then "<r:High>%d</r:High>" % rd.max else '' end)}


              return nd
            when ResponseDomainText
              td = Nokogiri::XML::Node.new 'd:TextDomain', @doc
              unless rd.maxlen.nil?
                td['maxLength'] = rd.maxlen
              end
              td.add_child "<r:Label><r:Content xml:lang=\"en-GB\">%{label}</r:Content></r:Label>" %
                               {label: rd.label}

              return td
          end
        end

        if qitem.response_domains.count > 1
          smrd = Nokogiri::XML::Node.new 'd:StructuredMixedResponseDomain', @doc
          inner_prev.add_next_sibling smrd
          qitem.response_domains.each do |rd|
            rdm = Nokogiri::XML::Node.new 'd:ResponseDomainInMixed', @doc
            rdm.add_child build_response_domain.call rd
            smrd.add_child rdm
          end
        elsif qitem.response_domains.count == 1
          inner_prev.add_next_sibling build_response_domain.call qitem.response_domains.first
        end

        unless qitem.instruction.nil?
          iif = Nokogiri::XML::Node.new 'd:InterviewerInstructionReference', @doc
          iif.add_child "<r:URN>%{urn}</r:URN><r:TypeOfObject>Instruction</r:TypeOfObject>" % {urn: @urns[:instructions][qitem.instruction_id]}
          inner_prev.add_next_sibling iif
          inner_prev = iif
        end

        prev = qi
      end
    end

    def build_qgs
      urn = Nokogiri::XML::Node.new 'r:URN', @doc
      urn.content = @urn_prefix + 'qgs-000002:1.0.0'
      @qgs.add_child urn
      qgsn = Nokogiri::XML::Node.new 'd:QuestionSchemeName', @doc
      qgsn.add_child "<r:String xml:lang=\"en-GB\">%{prefix}_qgs01</r:String>" %
                         {prefix: @instrument.prefix}
      urn.add_next_sibling qgsn
      prev = qgsn
      counter = 0
      @urns[QuestionGrid.name] = {}
      @instrument.question_grids.find_each do |qgrid|
        counter += 1
        qg = Nokogiri::XML::Node.new 'd:QuestionGrid', @doc
        prev.add_next_sibling qg
        urn = Nokogiri::XML::Node.new 'r:URN', @doc
        @urns[QuestionGrid.name][qgrid.id] = @urn_prefix + "qg-%06d:1.0.0" % counter
        urn.content = @urns[QuestionGrid.name][qgrid.id]
        qg.add_child urn
        uap = Nokogiri::XML::Node.new 'r:UserAttributePair', @doc
        uap.add_child "<r:AttributeKey>extension:Label</r:AttributeKey><r:AttributeValue>{\"en-GB\":\"%{label}\"}</r:AttributeValue>" %
                          {label: Util::question_label(qgrid.label)}
        urn.add_next_sibling uap
        qgn = Nokogiri::XML::Node.new 'd:QuestionGridName', @doc
        qgn.add_child "<r:String xml:lang=\"en-GB\">%{label}</r:String>" %
                          {label: qgrid.label}
        uap.add_next_sibling qgn
        qt = Nokogiri::XML::Node.new 'd:QuestionText', @doc
        qt['audienceLanguage'] = 'en-GB'
        qt.add_child "<d:LiteralText><d:Text>%{text}</d:Text></d:LiteralText>" %
                         {text: qgrid.literal}
        qgn.add_next_sibling qt

        add_grid_dimension = lambda do |rank, axis, cl_urn|
          gd = Nokogiri::XML::Node.new 'd:GridDimension', @doc
          gd['rank'] = rank
          gd['displayCode'] = 'false'
          gd['displayLabel'] = if qgrid.corner_label == axis then 'true' else 'false' end

          gd.add_child '<d:CodeDomain><r:CodeListReference>' +
            "<r:URN>%{urn}</r:URN>" % {urn: cl_urn} +
            '<r:TypeOfObject>CodeList</r:TypeOfObject>' +
              '</r:CodeListReference></d:CodeDomain>'
          return gd
        end

        gdy = add_grid_dimension.call('1', 'V', @urns[:codes][qgrid.vertical_code_list_id])
        qt.add_next_sibling gdy
        gdx = add_grid_dimension.call('2', 'H', @urns[:codes][qgrid.horizontal_code_list_id])
        gdy.add_next_sibling gdx

        inner_prev = gdx
        qgrid.response_domain_codes.each do |rdc|
          cd = Nokogiri::XML::Node.new 'd:CodeDomain', @doc
          cd.add_child "<r:CodeListReference><r:URN>%{urn}</r:URN><r:TypeOfObject>CodeList</r:TypeOfObject></r:CodeListReference>" %
                           {urn: @urns[:codes][rdc.code_list_id]}

          inner_prev.add_next_sibling cd
          inner_prev = cd
        end
        qgrid.response_domain_texts.each do |rdt|
          td = Nokogiri::XML::Node.new 'd:TextDomain', @doc
          unless rdt.maxlen.nil?
            td['maxLength'] = rdt.maxlen
          end
          td.add_child "<r:Label><r:Content xml:lang=\"en-GB\">%{label}</r:Content></r:Label>" %
                           {label: rdt.label}

          inner_prev.add_next_sibling td
          inner_prev = td
        end
        qgrid.response_domain_datetimes.each do |rdd|
          dd = Nokogiri::XML::Node.new 'd:DateTimeDomain', @doc
          dd.add_child "<r:DateFieldFormat>%{format}</r:DateFieldFormat><r:DateTypeCode>%{type}</r:DateTypeCode><r:Label><r:Content xml:lang=\"en-GB\">%{label}</r:Content></r:Label>" %
                           {label: rdd.label, type: rdd.datetime_type, format: rdd.format || ''}

          inner_prev.add_next_sibling dd
          inner_prev = dd
        end
        qgrid.response_domain_numerics.each do |rdn|
          nd = Nokogiri::XML::Node.new 'd:NumericDomain', @doc
          nd.add_child "<r:NumberRange>%{range}</r:NumberRange><r:NumericTypeCode>%{type}</r:NumericTypeCode><r:Label><r:Content xml:lang=\"en-GB\">%{label}</r:Content></r:Label>" %
                           {label: rdn.label, type: rdn.numeric_type, range: (if rdn.min then "<r:Low>%d</r:Low>" % rdn.min else '' end) + (if rdn.max then "<r:High>%d</r:High>" % rdn.max else '' end)}


          inner_prev.add_next_sibling nd
          inner_prev = nd
        end

        unless qgrid.instruction.nil?
          iif = Nokogiri::XML::Node.new 'd:InterviewerInstructionReference', @doc
          iif.add_child "<r:URN>%{urn}</r:URN><r:TypeOfObject>Instruction</r:TypeOfObject>" % {urn: @urns[:instructions][qgrid.instruction_id]}
          inner_prev.add_next_sibling iif
          inner_prev = iif
        end

        prev = qg
      end
    end

    def build_ccs
      urn = Nokogiri::XML::Node.new 'r:URN', @doc
      urn.content = @urn_prefix + 'ccs-000001:1.0.0'
      @ccs.add_child urn
      ccsn = Nokogiri::XML::Node.new 'd:ControlConstructSchemeName', @doc
      ccsn.add_child "<r:String xml:lang=\"en-GB\">%{prefix}_ccs01</r:String>" %
                        {prefix: @instrument.prefix}
      urn.add_next_sibling ccsn
      prev = ccsn
      @instrument.ccs_in_ddi_order.each do |cc|
        case cc
          when CcCondition
            con = Nokogiri::XML::Node.new 'd:IfThenElse', @doc
            urn = Nokogiri::XML::Node.new 'r:URN', @doc
            urn.content = @urn_prefix + 'if-%06d:1.0.0' % cc.id
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
              tcr.add_child '<r:URN>' + @urn_prefix + prefix + '-%06d:1.0.0' % cc.id + '</r:URN>'
              tcr.add_child '<r:TypeOfObject>Sequence</r:TypeOfObject>'
              prev.add_child tcr

              seth = Nokogiri::XML::Node.new 'd:Sequence', @doc
              seth.add_child '<r:URN>' + @urn_prefix + prefix + '-%06d:1.0.0' % cc.id + '</r:URN>'
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
                ccf = Nokogiri::XML::Node.new 'd:ControlConstructReference', @doc
                ccf_urn = Nokogiri::XML::Node.new 'r:URN', @doc
                ccf_urn.content = @urn_prefix + child.construct.class::URN_TYPE + '-%06d:1.0.0' % child.construct.id
                ccf.add_child ccf_urn
                ccf.add_child '<r:TypeOfObject>' + child.construct.class::TYPE + '</r:TypeOfObject>'
                seth_inner_prev.add_next_sibling ccf
                seth_inner_prev = ccf
              end
              return seth
            end

            if cc.children.where(branch: 0).count > 0
              seth = process_condition_branch.call(0, 'seth', 'then')
              prev.add_next_sibling seth
              prev = seth
            end

            if cc.children.where(branch: 1).count > 0
              seth = process_condition_branch.call(1, 'seel', 'else')
              prev.add_next_sibling seth
              prev = seth
            end

          when CcQuestion
            qc = Nokogiri::XML::Node.new 'd:QuestionConstruct', @doc
            urn = Nokogiri::XML::Node.new 'r:URN', @doc
            urn.content = @urn_prefix + 'qc-%06d:1.0.0' % cc.id
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

            qf = Nokogiri::XML::Node.new 'r:QuestionReference', @doc
            qf_urn = Nokogiri::XML::Node.new 'r:URN', @doc
            qf_urn.content = @urns[cc.question.class.name][cc.question.id]
            qf.add_child qf_urn
            qf.add_child '<r:TypeOfObject>' + cc.question.class::TYPE + '</r:TypeOfObject>'
            ru = Nokogiri::XML::Node.new 'd:ResponseUnit', @doc
            ru.content = cc.response_unit.label
            l.add_next_sibling qf
            qf.add_next_sibling ru
            prev.add_next_sibling qc
            prev = qc

          when CcStatement
            st = Nokogiri::XML::Node.new 'd:StatementItem', @doc
            urn = Nokogiri::XML::Node.new 'r:URN', @doc
            urn.content = @urn_prefix + 'si-%06d:1.0.0' % cc.id
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
            urn = Nokogiri::XML::Node.new 'r:URN', @doc
            urn.content = @urn_prefix + 'se-%06d:1.0.0' % cc.id
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
              ccf = Nokogiri::XML::Node.new 'd:ControlConstructReference', @doc
              urn = Nokogiri::XML::Node.new 'r:URN', @doc
              urn.content = @urn_prefix + child.construct.class::URN_TYPE + '-%06d:1.0.0' % child.construct.id
              ccf.add_child urn
              ccf.add_child '<r:TypeOfObject>' + child.construct.class::TYPE + '</r:TypeOfObject>'
              inner_prev.add_next_sibling ccf
              inner_prev = ccf
            end
            prev.add_next_sibling seq
            prev = seq
        end
      end
    end

    def build_is
      urn = Nokogiri::XML::Node.new 'r:URN', @doc
      urn.content = @urn_prefix + 'ins-000001:1.0.0'
      @is.add_child urn
      isn = Nokogiri::XML::Node.new 'd:InstrumentSchemeName', @doc
      isn.add_child "<r:String xml:lang=\"en-GB\">%{prefix}_is01</r:String>" %
                        {prefix: @instrument.prefix}
      urn.add_next_sibling isn
      i = Nokogiri::XML::Node.new 'd:Instrument', @doc
      i.add_child "<r:URN>%{urn}</r:URN>" % {urn: @urn_prefix + 'in-000001:1.0.0'}
      i.add_child "<d:InstrumentName><r:String xml:lang=\"en-GB\">%{title}</r:String></d:InstrumentName>" %
          {title: @instrument.label}
      i.add_child "<d:ControlConstructReference><r:URN>%{urn}</r:URN><r:TypeOfObject>Sequence</r:TypeOfObject></d:ControlConstructReference>" %
          {urn: @urn_prefix + "se-%06d:1.0.0" % @instrument.top_sequence.id}
      isn.add_next_sibling i
    end

    def doc
      @doc
    end
  end
end
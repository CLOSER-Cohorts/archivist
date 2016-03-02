module XML::DDI
  class Exporter
    def initialize(version)
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
        cn.add_next_sibling "<r:Label><r:Content xml:lang=\"en-GB\">%{label}</r:Content></r:Label>" %
                                 {label: cat.label}
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
      @urns[:code_lists] = {}
      @instrument.code_lists.find_each do |codelist|
        counter += 1
        cl = Nokogiri::XML::Node.new 'l:CodeList', @doc
        prev.add_next_sibling cl
        urn = Nokogiri::XML::Node.new 'r:URN', @doc
        @urns[:code_lists][codelist.id] = @urn_prefix + "cl-%06d:1.0.0" % counter
        urn.content = @urns[:code_lists][codelist.id]
        cl.add_child urn
        l = Nokogiri::XML::Node.new 'r:Label', @doc
        l.add_child "<r:Content xml:lang=\"en-GB\">%{label}</r:Content>" % {label: codelist.label}
        urn.add_next_sibling l
        inner_prev = l
        inner_counter = 0
        codelist.codes.find_each do |code|
          inner_counter += 1
          co = Nokogiri::XML::Node.new 'l:Code', @doc
          inner_prev.add_next_sibling co
          c_urn = Nokogiri::XML::Node.new 'r:URN', @doc
          c_urn.content = @urn_prefix + "co-%06d:1.0.0" % inner_counter
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
      @urns[:question_items] = {}
      @instrument.question_items.find_each do |qitem|
        counter += 1
        qi = Nokogiri::XML::Node.new 'd:QuestionItem', @doc
        prev.add_next_sibling qi
        urn = Nokogiri::XML::Node.new 'r:URN', @doc
        @urns[:question_items][qitem.id] = @urn_prefix + "qi-%06d:1.0.0" % counter
        urn.content = @urns[:question_items][qitem.id]
        qi.add_child urn
        uap = Nokogiri::XML::Node.new 'r:UserAttributePair', @doc
        uap.add_child "<r:AttributeKey>extension:Label</r:AttributeKey><r:AttributeValue>{\"en-GB\":\"%{label}\"}</r:AttributeValue>" %
        {label: qitem.label}
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
        qitem.response_domain_codes.each do |rdc|
          cd = Nokogiri::XML::Node.new 'd:CodeDomain', @doc
          cd.add_child "<r:CodeListReference><r:URN>%{urn}</r:URN><r:TypeOfObject>CodeList</r:TypeOfObject></r:CodeListReference>" %
              {urn: @urns[:code_lists][rdc.code_list_id]}

          inner_prev.add_next_sibling cd
          inner_prev = cd
        end
        qitem.response_domain_texts.each do |rdt|
          td = Nokogiri::XML::Node.new 'd:TextDomain', @doc
          td['maxLength'] = rdt.maxlen
          td.add_child "<r:Label><r:Content xml:lang=\"en-GB\">%{label}</r:Content></r:Label>" %
                           {label: rdt.label}

          inner_prev.add_next_sibling td
          inner_prev = td
        end

        prev = qi
      end
    end

    def doc
      @doc
    end
  end
end
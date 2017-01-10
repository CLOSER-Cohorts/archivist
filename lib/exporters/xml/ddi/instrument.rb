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

      exp = Exporters::XML::DDI::Instruction.new @doc
      @instrument.instructions.find_each do |instr|
        i = exp.V3_2 instr
        prev.add_next_sibling i
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
      exp = Exporters::XML::DDI::Category.new @doc
      @instrument.categories.find_each do |cat|
        c = exp.V3_2 cat
        prev.add_next_sibling c
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
      exp = Exporters::XML::DDI::CodeList.new @doc
      @instrument.code_lists.find_each do |codelist|
        cl = exp.V3_2 codelist
        prev.add_next_sibling cl
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

      exporters = {}
      exporters[::CcCondition] = Exporters::XML::DDI::CcCondition.new @doc
      exporters[::CcQuestion]  = Exporters::XML::DDI::CcQuestion.new @doc
      exporters[::CcStatement] = Exporters::XML::DDI::CcStatement.new @doc
      exporters[::CcSequence]  = Exporters::XML::DDI::CcSequence.new @doc
      exporters[::CcLoop]      = Exporters::XML::DDI::CcLoop.new @doc

      @instrument.ccs_in_ddi_order.each do |cc|
        @ccs << exporters[cc.class].V3_2(cc)
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
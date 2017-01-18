module Exporters::XML::DDI
  class Instrument < DdiExporterBase
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

      @iis = create_scheme('d:InterviewerInstructionScheme', '-iis-000001:1.0.0', @instrument.prefix + '_is01')
      @rp.add_child @iis

      @ccs = create_scheme('d:ControlConstructScheme', '-ccs-000001:1.0.0', @instrument.prefix + '_ccs01')
      @rp.add_child @ccs

      @qis = create_scheme('d:QuestionScheme', '-qs-000001:1.0.0', @instrument.prefix + '_qs01')
      @rp.add_child @qis

      @qgs = create_scheme('d:QuestionScheme', '-qs-000002:1.0.0', @instrument.prefix + '_qgs01')
      @rp.add_child @qgs

      @cs = create_scheme('l:CategoryScheme', '-cas-000001:1.0.0', @instrument.prefix + '_cs01')
      @rp.add_child @cs

      @cls = create_scheme('l:CodeListScheme', '-cos-000001:1.0.0', @instrument.prefix + '_cos01')
      @rp.add_child @cls

      @is = Nokogiri::XML::Node.new 'd:InstrumentScheme', @doc
      @cls.add_next_sibling @is
    end

    def build_iis
      build_scheme Exporters::XML::DDI::Instruction, @instrument.instructions, @iis
    end

    def build_cs
      build_scheme Exporters::XML::DDI::Category, @instrument.categories, @cs
    end

    def build_cls
      build_scheme Exporters::XML::DDI::CodeList, @instrument.code_lists, @cls
    end

    def build_qis
      build_scheme Exporters::XML::DDI::QuestionItem, @instrument.question_items, @qis
    end

    def build_qgs
      build_scheme Exporters::XML::DDI::QuestionGrid, @instrument.question_grids, @qgs
    end

    def build_ccs
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
    def create_scheme(tag, urn_suffix, name)
      s = Nokogiri::XML::Node.new tag, @doc
      s['versionDate'] = @datetimestring
      urn = Nokogiri::XML::Node.new 'r:URN', @doc
      urn.content = @urn_prefix + urn_suffix
      s.add_child urn
      sn = Nokogiri::XML::Node.new tag + 'Name', @doc
      sn.add_child "<r:String xml:lang=\"en-GB\">%{name}</r:String>" %
                        {name: name}
      s.add_child sn
      s
    end

    def build_scheme(exporter_klass, set, scheme)
      exporter = exporter_klass.new @doc
      set.find_each do |obj|
        scheme.add_child exporter.V3_2(obj)
      end
    end
  end
end
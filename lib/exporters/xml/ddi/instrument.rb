module Exporters::XML::DDI
  # DDI 3.2 XML Exporter for {::Instrument}
  #
  # {::Instrument} is a direct alias of DDI 3.2 Instrument.
  #
  # @example Exporting to file
  #   i = Instrument.first
  #   exp = Exporters::XML::DDI::Instrument.new
  #   exp.add_root_attributes
  #   filepath = exp.run i
  #
  # @example Exporting to string
  #   i = Instrument.first
  #   exp = Exporters::XML::DDI::Instrument.new
  #   exp.add_root_attributes
  #   exp.export_instrument i
  #   exp.build_rp
  #   exp.build_iis
  #   exp.build_cs
  #   exp.build_cls
  #   exp.build_qis
  #   exp.build_qgs
  #   exp.build_is
  #   exp.build_ccs
  #   xml_string = exp.doc.to_xml &:no_empty_tags
  #
  # @see ::Instruction
  class Instrument < DdiExporterBase
    # Creates the XML document for exporting to as
    # a DDIInstance
    def initialize
      @doc = Nokogiri::XML '<ddi:DDIInstance></ddi:DDIInstance>'
    end

    # Sets the essentiall attributes against the root node
    # and also takes the current time for the version date
    # for all schemes.
    def add_root_attributes
      @datetimestring = Time.now.strftime '%Y-%m-%dT%H:%M:%S%:z'
      @doc.root['versionDate'] = @datetimestring
      @doc.root['xmlns:d'] = 'ddi:datacollection:3_2'
      @doc.root['xmlns:ddi'] = 'ddi:instance:3_2'
      @doc.root['xmlns:g'] = 'ddi:group:3_2'
      @doc.root['xmlns:l'] = 'ddi:logicalproduct:3_2'
      @doc.root['xmlns:r'] = 'ddi:reusable:3_2'
    end

    # Performs a full instrument export to file
    #
    # @param [Instrument] instrument Instrument for exporting
    # @return [String] Path to the exported file
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

    # Creates the citation for the instance and creates the resoruce
    # package
    #
    # Both are added to @doc
    #
    # @param [Instrument] instrument Instrument for exporting
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

    # Populates the Resouse Package with all of the schemes
    # used in the questionnaire profile
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

    # Populates the InterviewerInstructionScheme with all of the instrument's {Instruction Instructions}
    def build_iis
      build_scheme Exporters::XML::DDI::Instruction, @instrument.instructions, @iis
    end

    # Populates the CategoryScheme with all of the instrument's {Category Categories}
    def build_cs
      build_scheme Exporters::XML::DDI::Category, categories, @cs
    end

    # Populates the CodeListScheme with all of the instrument's {CodeList CodeLists}
    def build_cls
      build_scheme Exporters::XML::DDI::CodeList, code_lists, @cls
    end

    # Populates the first QuestionScheme with all of the instrument's {QuestionItem QuestionItems}
    def build_qis
      build_scheme Exporters::XML::DDI::QuestionItem, question_items, @qis
    end

    # Populates the second QuestionScheme with all of the instrument's {QuestionGrid QuestionGrids}
    def build_qgs
      build_scheme Exporters::XML::DDI::QuestionGrid, question_grids, @qgs
    end

    # Populates the ControlConstructScheme with all of the instrument's constructs
    def build_ccs
      exporters = {}
      exporters[::CcCondition] = Exporters::XML::DDI::CcCondition.new @doc
      exporters[::CcQuestion]  = Exporters::XML::DDI::CcQuestion.new @doc
      exporters[::CcStatement] = Exporters::XML::DDI::CcStatement.new @doc
      exporters[::CcSequence]  = Exporters::XML::DDI::CcSequence.new @doc
      exporters[::CcLoop]      = Exporters::XML::DDI::CcLoop.new @doc

      control_constructs.each do |cc|
        @ccs << exporters[cc.class].V3_2(cc)
      end
    end

    def control_constructs
      @control_constructs ||= @instrument.ccs_in_ddi_order
    end

    def code_lists
      @code_lists ||= ::CodeList.where(id:
        (
          ::CodeList.joins(response_domain_code: :rds_qs).where('rds_qs.question_id IN (?)', question_items.pluck(:id) + question_grids.pluck(:id)).pluck(:id) +
          ::CodeList.joins(:qgrids_via_h).where('question_grids.id IN (?)', question_grids.pluck(:id)).pluck(:id) +
          ::CodeList.joins(:qgrids_via_v).where('question_grids.id IN (?)', question_grids.pluck(:id)).pluck(:id)
        ).uniq
      )
    end

    def categories
      @categories ||= ::Category.joins(codes: :code_list).where('code_lists.id IN (?)', code_lists.pluck(:id)).distinct
    end

    def question_items
      @question_items ||= ::QuestionItem.joins(:cc_questions).where('cc_questions.id IN (?)', control_constructs.select{|cc| cc.class == CcQuestion && cc.question_type == 'QuestionItem'}.map(&:id)).distinct
    end

    def question_grids
      @question_grids ||= ::QuestionGrid.joins(:cc_questions).where('cc_questions.id IN (?)', control_constructs.select{|cc| cc.class == CcQuestion && cc.question_type == 'QuestionGrid'}.map(&:id)).distinct
    end

    # Populates the InstrumentScheme with the {::Instrument} details
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
          {title: CGI::escapeHTML(@instrument.label.to_s)}
      i.add_child create_reference_string 'd:ControlConstructReference', @instrument.top_sequence
      isn.add_next_sibling i
    end

    # Accessor reader for @doc
    #
    # @return [Nokogiri::XML::Document] Export XML document
    def doc
      @doc
    end

    private  # Private methods
    # Generic builder to create a scheme
    #
    # @param [String] tag Name of scheme to be created
    # @param [String] urn_suffix Identifing string for scheme URN
    # @param [String] name Name of the scheme
    # @return [Nokogiri::XML::Node] New XML scheme node
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

    # Generic method for populating a scheme with items
    #
    # @param [DdiExporterBase] exporter_klass Exporter class for item
    # @param [ActiveRecord::Associations::CollectionProxy] set Collection of items for export to scheme
    # @param [Nokogiri::XML::Node] scheme Scheme for populating
    def build_scheme(exporter_klass, set, scheme)
      exporter = exporter_klass.new @doc
      set.find_each do |obj|
        scheme.add_child exporter.V3_2(obj)
      end
    end
  end
end

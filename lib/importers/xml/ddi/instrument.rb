module Importers::XML::DDI
  class Instrument < DdiImporterBase
    def initialize(thing, options = {})
      if thing.is_a? String
        @doc = open(thing) { |f| Nokogiri::XML(f) }
      else
        document = Document.find thing
        @doc = Nokogiri::XML document.file_contents
      end
      @doc.remove_namespaces!
      @counters = {}
    end

   def cancel
     @instrument.destroy
   end

    def import
      Realtime.do_silently do
        @instrument = Importers::XML::DDI::Instrument.build_instrument @doc
        import_category_schemes
        import_code_list_schemes
        import_instruction_schemes
        import_question_schemes
        read_constructs
      end
    end

    def import_category_schemes
      import_scheme Importers::XML::DDI::Category, 'CategoryScheme'
    end

    def import_code_list_schemes
      import_scheme Importers::XML::DDI::CodeList, 'CodeListScheme'
    end

    def import_instruction_schemes
      import_scheme Importers::XML::DDI::Instruction, 'InterviewerInstructionScheme'
    end

    def import_question_schemes
      import_scheme Importers::XML::DDI::Question, 'QuestionScheme'
    end

    def import_scheme(import_klass, scheme_tag_name)
      importer = import_klass.new @instrument
      @doc.xpath('//' + scheme_tag_name).each do |scheme|
        importer.XML_scheme scheme
      end
    end

    def read_constructs
      seq = doc.xpath('//ControlConstructScheme/Sequence').first
      cc_seq = @instrument.top_sequence
      begin
        cc_seq.label = seq.at_xpath('./ConstructName/String').content
      rescue
        if (label = seq.at_xpath('./Label/Content')).nil?
          cc_seq.label = label
        else
          cc_seq.label = 'Missing label'
        end
      end
      @response_unit_index = {}
      read_sequence_children(seq, cc_seq)
    end

    def read_sequence_children(node, parent, branch = nil)
      position_counter = 0

      sub_sequence = lambda do |node, search, cc, branch|
        ref = node.at_xpath(search)
        return if ref.nil?
        seq = Reference.find_node node, ref
        unless seq.nil?
          read_sequence_children seq, cc, branch
        end
      end

      node.xpath('./ControlConstructReference').each do |child_ref|
        position_counter += 1
        child = Reference.find_node doc, child_ref
        if child.name == 'Sequence'
          cc_s = CcSequence.new
          @instrument.cc_sequences << cc_s
          begin
            cc_s.label = child.at_xpath('./ConstructName/String').content
          rescue
            if (label = child.at_xpath('./Label/Content')).nil?
              cc_s.label = label
            else
              cc_s.label = 'Missing label'
            end
          end
          cc_s.position = position_counter

          cc_s.branch = branch
          cc_s.parent = parent

          read_sequence_children(child, cc_s)
          cc_s.save!
        elsif child.name == 'StatementItem'
          cc_s = CcStatement.new
          @instrument.cc_statements << cc_s
          begin
            cc_s.label = child.at_xpath('./ConstructName/String').content
          rescue
            if (label = child.at_xpath('./Label/Content')).nil?
              cc_s.label = label
            else
              cc_s.label = 'Missing label'
            end
          end
          cc_s.position = position_counter
          cc_s.branch = branch
          cc_s.literal = child.at_xpath('./DisplayText/LiteralText/Text').content

          cc_s.parent = parent
          cc_s.save!

        elsif child.name == 'QuestionConstruct'
          q_ref = child.at_xpath('./QuestionReference')
          # ApplicationRecord can perform generic queries
          base_question = ApplicationRecord.find_by_identifier(
              'urn',
              extract_urn_identifier(q_ref)
          )
          cc_q = CcQuestion.new
          cc_q.question = base_question
          begin
            ru_val = child.at_xpath('./ResponseUnit').content
          rescue
            ru_val = 'Default interviewee'
          end
          if @response_unit_index.has_key? ru_val
            ru = @response_unit_index[ru_val]
          else
            ru = ResponseUnit.new label: ru_val
            @instrument.response_units << ru
            @response_unit_index[ru_val] = ru
          end
          cc_q.response_unit = ru
          @instrument.cc_questions << cc_q
          begin
            cc_q.label = child.at_xpath('./ConstructName/String').content
          rescue
            if (label = child.at_xpath('./Label/Content')).nil?
              cc_q.label = label
            else
              cc_q.label = 'Missing label'
            end
          end
          cc_q.position = position_counter
          cc_q.branch = branch
          cc_q.parent = parent
          cc_q.save!
        elsif child.name == 'IfThenElse'
          cc_c = CcCondition.new
          @instrument.cc_conditions << cc_c
          begin
            cc_c.label = child.at_xpath('./ConstructName/String').content
          rescue
            if (label = child.at_xpath('./Label/Content')).nil?
              cc_c.label = label
            else
              cc_c.label = 'Missing label'
            end
          end
          cc_c.position = position_counter
          cc_c.branch = branch
          begin
            cc_c.literal = child.at_xpath('./IfCondition/Description/Content').content
          rescue
            cc_c.literal = 'Missing text'
          end
          begin
            cc_c.logic = child.at_xpath('./IfCondition/Command/CommandContent').content
          rescue
            cc_c.logic = ''
          end

          cc_c.parent = parent
          cc_c.save!

          sub_sequence.call child, './ThenConstructReference', cc_c, 0
          sub_sequence.call child, './ElseConstructReference', cc_c, 1

        elsif child.name == 'Loop'

          cc_l = CcLoop.new
          @instrument.cc_loops << cc_l
          start_node = child.at_xpath('./InitialValue/Command/CommandContent')
          end_node = child.at_xpath('./EndValue/Command/CommandContent')
          while_node = child.at_xpath('./LoopWhile/Command/CommandContent')
          begin
            cc_l.label = child.at_xpath('./ConstructName/String').content
          rescue
            if (label = child.at_xpath('./Label/Content')).nil?
              cc_l.label = label
            else
              cc_l.label = 'Missing label'
            end
          end
          cc_l.position = position_counter
          cc_l.branch = branch
          unless start_node.nil?
            pieces = start_node.content.split(/\W\D\s/)
            cc_l.loop_var = pieces[0]
            cc_l.start_val = pieces[1]
          end
          unless end_node.nil?
            pieces = end_node.content.split(/\W\D\s/)
            cc_l.end_val = pieces[1]
          end
          unless while_node.nil? then
            cc_l.loop_while = while_node.content
          end

          cc_l.parent = parent
          cc_l.save!

          sub_sequence.call child, './ControlConstructReference', cc_l, nil

        end
      end

    end

    def self.build_instrument(doc, options= {})
      save = defined?(options[:save]) ? true : options[:save]
      duplicate = defined?(options[:duplicate]) ? :do_nothing : options[:duplicate]

      i = ::Instrument.new
      begin
        i.label = doc.xpath('//InstrumentName//String').first.content
      rescue
        i.label = 'Missing name'
      end
      urn_pieces = doc.xpath('//URN').first.content.split(':')
      i.agency = urn_pieces[2]
      i.prefix = urn_pieces[3].split('-ddi-')[0]
      instruments = ::Instrument.where({prefix: i.prefix})
      if instruments.length > 0
        Rails.logger.info 'Duplicate instrument(s) found while importing XML.'
        if duplicate == :do_nothing
          raise Exceptions::ImportError, 'Aborting XML import. Consider passing a duplicate option to importer.'
        else
          if duplicate == :update || duplicate == :replace
            if instruments.length == 1
              if duplicate == :update
                i = instruments.first
              else
                instruments.first.destroy
              end
            else
              raise Exceptions::ImportError, 'Aborting XML import. Cannot update or replace instrument as multiple duplicates found.'
            end
          end
        end
      end
      i.version = '1.0'
      if save
        i.save!
      end
      return i
    end

    def doc
      @doc
    end

    def object
      @instrument
    end
  end

  class Reference
    class << self
      def find_node(doc, ref)
        urn = ref.at_xpath('./URN')&.content
        type = ref.at_xpath('./TypeOfObject')&.content
        if urn.nil?
          agency_node = ref.at_xpath('./Agency')
          id_node = ref.at_xpath('./ID')
          version_node = ref.at_xpath('./Version')
          urn = compose(agency_node, id_node, version_node)
        end
        doc.at_xpath("//*[local-name() = '#{type}']/URN[text()='#{urn}']")&.parent
      end

      def compose(agency_node, id_node, version_node)
        'urn:ddi:%{agency}:%{id}:%{version}' % {
            agency:   agency_node&.content,
            id:       id_node&.content,
            version:  version_node&.content
        }
      end
    end
  end
  private_constant :Reference
end

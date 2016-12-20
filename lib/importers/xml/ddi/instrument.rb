module Importers::XML::DDI
  class Instrument
    def initialize(thing, options = {})
      if thing.is_a? String
        @doc = open(thing) { |f| Nokogiri::XML(f) }
      else
        document = Document.find thing
        @doc = Nokogiri::XML document.file_contents
      end
      @doc.remove_namespaces!
      @import_question_grids = options['question_grids'].nil? ||
          (options['question_grids'] == 'true' && options['question_grids'].is_a?(String)) ||
          (!!options['question_grids'] == options['question_grids'] && options['question_grids']) ? true : false
      @counters = {}
    end

    def parse
      Realtime.do_silently do
        @instrument = Importers::XML::DDI::Instrument.build_instrument @doc
        read_code_lists
        read_instructions
        read_response_domains
        read_questions
        read_constructs
      end
    end

    def read_code_lists
      #Read categories first
      categories = @doc.xpath('//Category')
      categories.each do |category|
        begin
          cat = Category.new label: category.at_xpath('./Label/Content').content
        rescue
          cat = Category.new label: ''
        end
        Reference[category] = cat
        @instrument.categories << cat
      end
      @counters['categories'] = categories.length

      #Read code lists and codes together
      code_lists = @doc.xpath('//CodeList')
      @counters['code_lists'] = code_lists.length
      @counters['codes'] = 0

      code_lists.each do |code_list|
        codes_to_add = []
        codes = code_list.xpath('./Code')
        @counters['codes'] += codes.length
        order_counter = 0
        codes.each do |code|
          order_counter += 1
          begin
            co = Code.new({value: code.at_xpath('./Value').content, order: order_counter})
            co.category = Reference[code.at_xpath('./CategoryReference')]
            codes_to_add << co
          rescue
            Rails.logger.warn 'Code failed to be imported.'
          end
        end

        begin
          cl = CodeList.new label: code_list.at_xpath('./Label/Content').content
        rescue
          cl = CodeList.new label: codes_to_add.map {|c| c.category.label.gsub(/\s*(\S)\S*/, '\1')}.join('_')
        end
        Reference[code_list] = cl
        @instrument.code_lists << cl
        codes_to_add.each {|c| cl.codes << c}
      end

      #Read response domain code
      @rdcs_created = []
      rdc_refs = @doc.xpath('//QuestionGrid/CodeDomain/CodeListReference | ' +
                                '//QuestionItem/CodeDomain/CodeListReference | ' +
                                '//QuestionGrid/StructuredMixedResponseDomain/ResponseDomainInMixed/CodeDomain/CodeListReference | ' +
                                '//QuestionItem/StructuredMixedResponseDomain/ResponseDomainInMixed/CodeDomain/CodeListReference | ' +
                                '//QuestionGrid/StructuredMixedGridResponseDomain/GridResponseDomain/CodeDomain/CodeListReference'
      )
      rdc_refs.each do |ref|
        unless @rdcs_created.include? ref.content
          @rdcs_created << ref.content
          Reference[ref].response_domain = true
          unless (cardinality = ref.parent.at_xpath('ResponseCardinality')).nil?
            Reference[ref].response_domain.min_responses = cardinality['minimumResponses']
            Reference[ref].response_domain.max_responses = cardinality['maximumResponses']
          end
          Reference[ref].save!
        end
      end
    end

    def read_instructions
      instructions = @doc.xpath('//Instruction')
      @counters['instructions'] = instructions.length
      instructions.each do |instruction|
        instr = Instruction.new({text: instruction.at_xpath('./InstructionText/LiteralText/Text').content})
        @instrument.instructions << instr
        Reference[instruction] = instr
      end
    end

    def read_response_domains
      text_domains = @doc.xpath('//TextDomain')
      @counters['response_domain_texts'] = text_domains.length
      @response_domain_index ||= {}
      text_domains.each do |text_domain|
        begin
          index_label = text_domain.at_xpath('Label/Content')&.content
          if index_label.nil?
            if text_domain['maxLength'].nil?
              index_label = 'MISSING LABEL'
            else
              index_label = 'max:' + text_domain['maxLength']
            end
          end
          unless @response_domain_index.has_key? 'T' + index_label
            rdt = ResponseDomainText.new({label: index_label})
            unless text_domain['maxLength'].nil?
              rdt.maxlen = text_domain['maxLength'].to_i
            end
            @instrument.response_domain_texts << rdt
            @response_domain_index['T' + index_label] = rdt
          end
        rescue
          Rails.logger.info 'Deferring text domain creation.'
        end
      end

      numeric_domains = @doc.xpath('//NumericDomain')
      @counters['response_domain_numerics'] = numeric_domains.length
      @response_domain_index ||= {}
      numeric_domains.each do |numeric_domain|
        begin
          index_label = numeric_domain.at_xpath('./Label/Content')&.content
          unless @response_domain_index.has_key? 'N' + index_label.to_s
            rdn = ResponseDomainNumeric.new({
                                                label: index_label,
                                                numeric_type: numeric_domain.at_xpath('NumericTypeCode').content
                                            })
            rdn.min = numeric_domain.at_xpath('NumberRange/Low')&.content
            rdn.max = numeric_domain.at_xpath('NumberRange/High')&.content
            @instrument.response_domain_numerics << rdn
            @response_domain_index['N' + index_label] = rdn
          end
        rescue
          Rails.logger.info 'Deferring numeric domain creation.'
        end
      end

      datetime_domains = @doc.xpath('//DateTimeDomain')
      @counters['response_domain_datetimes'] = datetime_domains.length
      @response_domain_index ||= {}
      datetime_domains.each do |datetime_domain|
        begin
          index_label = datetime_domain.at_xpath('Label/Content')&.content
          if not @response_domain_index.has_key? 'D' + index_label
            rdd = ResponseDomainDatetime.new({label: index_label, datetime_type: datetime_domain.at_xpath('DateTypeCode').content})
            format = datetime_domain.at_xpath('DateFieldFormat').content
            if format.length > 0
              rdd.format = format
            end
            @instrument.response_domain_datetimes << rdd
            @response_domain_index['D' + index_label] = rdd
          end
        rescue
          Rails.logger.info 'Deferring datetime domain creation.'
        end
      end
    end

    def read_questions
      read_question_items
      if @import_question_grids
        read_question_grids
      end
    end

    def read_question_items
      question_items = @doc.xpath('//QuestionItem')
      @counters['question_items'] = question_items.length
      question_items.each do |question_item|
        qi = QuestionItem.new({label: question_item.at_xpath('./QuestionItemName/String').content})
        begin
          qi.literal = question_item.at_xpath('./QuestionText/LiteralText/Text').content
        rescue
          qi.literal = ''
        end
        Reference[question_item] = qi

        #Adding response domains
        rds = question_item.xpath('./CodeDomain | '\
          './NumericDomain | '\
          './TextDomain | '\
          './DateTimeDomain'\
        )

        @instrument.question_items << qi

        order_counter = 0
        rds.each do |rd|
          order_counter += 1
          type = rd.name
          if type == 'CodeDomain'
            RdsQs.create({
                             question: qi,
                             response_domain: Reference[rd.at_xpath('./CodeListReference')].response_domain,
                             rd_order: order_counter
                         })
          else
            if type == 'NumericDomain'
              prefix_char = 'N'
              klass = ResponseDomainNumeric
            elsif type == 'TextDomain'
              prefix_char = 'T'
              klass = ResponseDomainText
            elsif type == 'DatetimeDomain'
              prefix_char = 'D'
              klass = ResponseDomainDatetime
            else
              Rails.logger.warn 'ResponseDomain not supported'
              next
            end

            if (response_domain = @response_domain_index[prefix_char.to_s + rd.at_xpath('Label/Content')&.content.to_s]).nil?
              response_domain = klass.new label: 'MISSING LABEL'
              response_domain.instrument = @instrument
              response_domain.save!
            end
            RdsQs.create({
                             question: qi,
                             response_domain: response_domain,
                             rd_order: order_counter
                         })
          end
        end

        #Adding instruction
        instr = question_item.at_xpath('./InterviewerInstructionReference')
        unless instr.nil?
          qi.association(:instruction).writer Reference[instr]
        end
        qi.save!
      end
    end

    def read_question_grids
      question_grids = @doc.xpath('//QuestionGrid')
      @counters['question_grids'] = question_grids.length
      question_grids.each do |question_grid|
        qg = QuestionGrid.new({label: question_grid.at_xpath('./QuestionGridName/String').content})
        qg.literal = question_grid.at_xpath('./QuestionText/LiteralText/Text').content
        Reference[question_grid] = qg
        qg_X = question_grid.at_xpath("./GridDimension[@rank='2']/CodeDomain/CodeListReference")
        qg_Y = question_grid.at_xpath("./GridDimension[@rank='1']/CodeDomain/CodeListReference")
        qg.horizontal_code_list = Reference[qg_X]
        roster = question_grid.at_xpath("./GridDimension[@rank='1']/Roster")
        unless roster.nil?
          qg.roster_label = roster.at_xpath('./Label/r:Content').content
          qg.roster_rows = roster.attribute('minimumRequired').value.nil? ? 0 : roster.attribute('minimumRequired').value.to_i
        end
        unless qg_Y.nil?
          qg.vertical_code_list = Reference[qg_Y]
        end
        corner = question_grid.at_xpath("./GridDimension[@displayLabel='true']")

        @instrument.question_grids << qg
        unless corner.nil?
          qg.corner_label = corner.attribute('rank').value.to_i == 1 ? 'V' : 'H'
        end

        read_q_rds = lambda do |obj, collection, index_prefix, arr|
          collection.each do |x|
            if x.parent.name == "GridResponseDomain"
              RdsQs.create({
                               question: obj,
                               response_domain: @response_domain_index[
                                   index_prefix +
                                       x
                                           .at_xpath('./Label/Content')
                                           .content
                               ],
                               code_id: x
                                            .parent
                                            .at_xpath("./GridAttachment/CellCoordinatesAsDefined/SelectDimension[@rank='2']")
                                            .attribute('specificValue')
                                            .value
                                            .to_i
                           })
            else
              obj.send(arr) << @response_domain_index[index_prefix + x.at_xpath('./Label/Content').content]
            end
          end
        end

        number_of_code_domains_as_axis = 0
        rdcs = question_grid.xpath('.//CodeDomain')
        rdcs.each do |rdc|
          if not rdc.parent.name == 'GridDimension'
            if rdc.parent.name == 'GridResponseDomain'
              RdsQs.create({
                               question: qg,
                               response_domain: Reference[rdc.at_xpath('./CodeListReference')].response_domain,
                               code_id: rdc.parent.at_xpath("./GridAttachment/CellCoordinatesAsDefined/SelectDimension[@rank='2']").attribute('specificValue').value.to_i
                           })
            else
              qg.response_domain_codes << Reference[rdc.at_xpath('./CodeListReference')].response_domain
            end
          else
            number_of_code_domains_as_axis += 1
          end
        end
        read_q_rds.call(
            qg,
            question_grid.xpath('.//NumericDomain'),
            'N',
            'response_domain_numerics'
        )
        read_q_rds.call(
            qg,
            question_grid.xpath('.//TextDomain'),
            'T',
            'response_domain_texts'
        )
        read_q_rds.call(
            qg,
            question_grid.xpath('.//DateTimeDomain'),
            'D',
            'response_domain_datetimes'
        )

        collection = question_grid.xpath('.//CodeDomain | .//NumericDomain | .//TextDomain | .//DateTimeDomain')

        if (collection.count - number_of_code_domains_as_axis) == 1 && qg.horizontal_code_list.codes.count > 1
          base = qg.rds_qs.first.dup
          qg.horizontal_code_list.codes.each_with_index do |c, i|
            unless i == 0
              qg.rds_qs << base.dup
            end
            newest_junction = qg.rds_qs.last
            newest_junction.code_id = c.value.to_i
            newest_junction.save!
          end
        end

        #Adding instruction
        instr = question_grid.at_xpath('./InterviewerInstructionReference')
        if not instr.nil?
          qg.association(:instruction).writer Reference[instr]
        end
        qg.save!
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
          @instrument.sequences << cc_s
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
          parent.children << cc_s.cc
          read_sequence_children(child, cc_s)
          cc_s.save!
        elsif child.name == 'StatementItem'
          cc_s = CcStatement.new
          @instrument.statements << cc_s
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
          parent.children << cc_s.cc
          cc_s.save!
        elsif child.name == 'QuestionConstruct'
          q_ref = child.at_xpath('./QuestionReference')
          base_question = Reference[q_ref]
          unless base_question.is_a?(QuestionGrid) && !@import_question_grids
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
            @instrument.questions << cc_q
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
            parent.children << cc_q.cc
            cc_q.save!
          end
        elsif child.name == 'IfThenElse'
          cc_c = CcCondition.new
          @instrument.conditions << cc_c
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

          parent.children << cc_c.cc
          cc_c.save!

          sub_sequence.call child, './ThenConstructReference', cc_c, 0
          sub_sequence.call child, './ElseConstructReference', cc_c, 1

        elsif child.name == 'Loop'

          cc_l = CcLoop.new
          @instrument.loops << cc_l
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
          parent.children << cc_l.cc
          cc_l.save!

          sub_sequence.call child, './ControlConstructReference', cc_l

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
      i.version = "1.0"
      if save
        i.save!
      end
      return i
    end

    def doc
      @doc
    end

    def instrument
      @instrument
    end
  end

  class Reference
    class << self
      @@indexes = {}

      def find_node(doc, ref)
        urn = ref.at_xpath('./URN')&.content
        type = ref.at_xpath('./TypeOfObject')&.content
        if urn.nil?
          agency_node = ref_node.at_xpath('./Agency')
          id_node = ref_node.at_xpath('./ID')
          version_node = ref_node.at_xpath('./Version')
          urn = compose(agency_node, id_node, version_node)
        end
        doc.at_xpath("//*[local-name() = '#{type}']/URN[text()='#{urn}']']")&.parent
      end

      def []=(node, obj)
        type = node.name
        @@indexes[type] = {} if @@indexes[type].nil?
        urn_node = node.at_xpath './URN'
        @@indexes[type][urn_node.content] = obj
      end

      def [](ref_node)
        type = ref_node.at_xpath('./TypeOfObject').content
        urn_node = ref_node.at_xpath('./URN')
        return @@indexes[type][urn_node.content] unless urn_node.nil?
        agency_node = ref_node.at_xpath('./Agency')
        id_node = ref_node.at_xpath('./ID')
        version_node = ref_node.at_xpath('./Version')
        return @@indexes[type][compose(agency_node, id_node, version_node)]
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

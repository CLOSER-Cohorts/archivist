module XML::CADDIES
  class Importer
    def initialize(filepath)
      @doc = open(filepath) { |f| Nokogiri::XML(f) }
      @counters = {}
    end

    def parse
      Realtime.do_silently do
        @instrument = Importer.build_instrument @doc
        read_code_lists
        read_instructions
        read_response_domains
        read_questions
        read_constructs
      end
    end

    def read_code_lists
      #Read categories first
      categories = @doc.xpath("//l:Category")
      @category_index = {}
      categories.each do |category|
        cat = Category.new({label: category.at_xpath("./r:Label/r:Content").content})
        @category_index[category.at_xpath('./r:URN').content] = cat
        @instrument.categories << cat
      end
      @counters['categories'] = categories.length

      #Read code lists and codes together
      code_lists = @doc.xpath("//l:CodeList")
      @counters['codes'] = code_lists.length
      @counters['codes'] = 0
      @code_list_index = {}
      code_lists.each do |code_list|
        cl = CodeList.new({label: code_list.at_xpath("./r:Label/r:Content").content})
        @code_list_index[code_list.at_xpath('./r:URN').content] = cl
        @instrument.code_lists << cl
        codes = code_list.xpath("./l:Code")
        @counters['codes'] += codes.length
        order_counter = 0
        codes.each do |code|
          order_counter += 1
          co = Code.new({value: code.at_xpath("./r:Value").content, order: order_counter})
          co.category = @category_index[code.at_xpath("./r:CategoryReference/r:URN").content]
          cl.codes << co
        end
      end

      #Read response domain code
      @rdcs_created = []
      rdc_urns = @doc.xpath("//d:QuestionGrid/d:CodeDomain/r:CodeListReference/r:URN | " +
                                "//d:QuestionItem/d:CodeDomain/r:CodeListReference/r:URN | " +
                                "//d:QuestionGrid/d:StructuredMixedResponseDomain/d:ResponseDomainInMixed/d:CodeDomain/r:CodeListReference/r:URN | " +
                                "//d:QuestionItem/d:StructuredMixedResponseDomain/d:ResponseDomainInMixed/d:CodeDomain/r:CodeListReference/r:URN | " +
                                "//d:QuestionGrid/d:StructuredMixedGridResponseDomain/d:GridResponseDomain/d:CodeDomain/r:CodeListReference/r:URN"
      )
      rdc_urns.each do |urn|
        if not @rdcs_created.include? urn.content
          @rdcs_created << urn.content
          @code_list_index[urn.content].response_domain = true
          @code_list_index[urn.content].save!
        end
      end
    end

    def read_instructions
      instructions = @doc.xpath("//d:Instruction")
      @counters['instructions'] = instructions.length
      @instruction_index = {}
      instructions.each do |instruction|
        instr = Instruction.new({text: instruction.at_xpath("d:InstructionText/d:LiteralText/d:Text").content})
        @instrument.instructions << instr
        @instruction_index[instruction.at_xpath("r:URN").content] = instr
      end
    end

    def read_response_domains
      text_domains = @doc.xpath("//d:TextDomain")
      @counters['response_domain_texts'] = text_domains.length
      @response_domain_index ||= {}
      text_domains.each do |text_domain|
        index_label = text_domain.at_xpath("r:Label/r:Content").content
        if not @response_domain_index.has_key? "T" + index_label
          rdt = ResponseDomainText.new({label: index_label})
          if not text_domain["maxLength"].nil?
            rdt.maxlen = text_domain["maxLength"].to_i
          end
          @instrument.response_domain_texts << rdt
          @response_domain_index["T" + index_label] = rdt
        end
      end

      numeric_domains = @doc.xpath("//d:NumericDomain")
      @counters['response_domain_numerics'] = numeric_domains.length
      @response_domain_index ||= {}
      numeric_domains.each do |numeric_domain|
        index_label = numeric_domain.at_xpath("r:Label/r:Content").content
        if not @response_domain_index.has_key? "N" + index_label
          rdn = ResponseDomainNumeric.new({label: index_label, numeric_type: numeric_domain.at_xpath("r:NumericTypeCode").content})
          min = numeric_domain.at_xpath("r:NumberRange/r:Low")
          max = numeric_domain.at_xpath("r:NumberRange/r:High")
          if not min.nil? then
            rdn.min = min.content
          end
          if not max.nil? then
            rdn.max = max.content
          end
          @instrument.response_domain_numerics << rdn
          @response_domain_index["N" + index_label] = rdn
        end
      end

      datetime_domains = @doc.xpath("//d:DateTimeDomain")
      @counters['response_domain_datetimes'] = datetime_domains.length
      @response_domain_index ||= {}
      datetime_domains.each do |datetime_domain|
        index_label = datetime_domain.at_xpath("r:Label/r:Content").content
        if not @response_domain_index.has_key? "D" + index_label
          rdd = ResponseDomainDatetime.new({label: index_label, datetime_type: datetime_domain.at_xpath("r:DateTypeCode").content})
          format = datetime_domain.at_xpath("r:DateFieldFormat").content
          if format.length > 0
            rdd.format = format
          end
          @instrument.response_domain_datetimes << rdd
          @response_domain_index["D" + index_label] = rdd
        end
      end
    end

    def read_questions
      read_question_items
      read_question_grids
    end

    def read_question_items
      question_items = @doc.xpath("//d:QuestionItem")
      @counters['question_items'] = question_items.length
      @question_item_index = {}
      question_items.each do |question_item|
        qi = QuestionItem.new({label: question_item.at_xpath("d:QuestionItemName/r:String").content})
        qi.literal = question_item.at_xpath("d:QuestionText/d:LiteralText/d:Text").content
        @question_item_index[question_item.at_xpath("./r:URN").content] = qi

        #Adding response domains
        rds = question_item.xpath('./d:CodeDomain/r:CodeListReference/r:URN | '\
          './d:StructuredMixedResponseDomain/d:ResponseDomainInMixed/d:CodeDomain/r:CodeListReference/r:URN | '\
          './d:NumericDomain/r:Label/r:Content | '\
          './d:StructuredMixedResponseDomain/d:ResponseDomainInMixed/d:NumericDomain/r:Label/r:Content | '\
          './d:TextDomain/r:Label/r:Content | '\
          './d:StructuredMixedResponseDomain/d:ResponseDomainInMixed/d:TextDomain/r:Label/r:Content | '\
          './d:DateTimeDomain/r:Label/r:Content | '\
          './d:StructuredMixedResponseDomain/d:ResponseDomainInMixed/d:DateTimeDomain/r:Label/r:Content'
        )

        @instrument.question_items << qi

        order_counter = 0
        rds.each do |rd|
          order_counter += 1
          type = rd.parent.parent.name
          if type == 'CodeDomain'
            RdsQs.create({
                             question: qi,
                             response_domain: @code_list_index[rd.content].response_domain,
                             rd_order: order_counter
                         })
          else
            prefix_char = type == 'NumericDomain' ? 'N' : (type == 'TextDomain' ? 'T' : 'D')
            RdsQs.create({
                             question: qi,
                             response_domain: @response_domain_index[prefix_char + rd.content],
                             rd_order: order_counter
                         })
          end
        end

        #Adding instruction
        instr = question_item.at_xpath("./d:InterviewerInstructionReference/r:URN")
        if not instr.nil?
          qi.association(:instruction).writer @instruction_index[instr.content]
        end
      end
    end

    def read_question_grids
      question_grids = @doc.xpath("//d:QuestionGrid")
      @counters['question_grids'] = question_grids.length
      @question_grid_index = {}
      question_grids.each do |question_grid|
        qg = QuestionGrid.new({label: question_grid.at_xpath("d:QuestionGridName/r:String").content})
        qg.literal = question_grid.at_xpath("d:QuestionText/d:LiteralText/d:Text").content
        @question_grid_index[question_grid.at_xpath("./r:URN").content] = qg
        qg_X = question_grid.at_xpath("d:GridDimension[@rank='2']/d:CodeDomain/r:CodeListReference/r:URN")
        qg_Y = question_grid.at_xpath("d:GridDimension[@rank='1']/d:CodeDomain/r:CodeListReference/r:URN")
        qg.horizontal_code_list = @code_list_index[qg_X.content]
        roster = question_grid.at_xpath("./d:GridDimension[@rank='1']/d:Roster")
        unless roster.nil?
          qg.roster_label = roster.at_xpath("./r:Label/r:Content").content
          qg.roster_rows = roster.attribute('minimumRequired').value.nil? ? 0 : roster.attribute('minimumRequired').value.to_i
        end
        unless qg_Y.nil?
          qg.vertical_code_list = @code_list_index[qg_Y.content]
        end
        corner = question_grid.at_xpath("d:GridDimension[@displayLabel='true']")

        @instrument.question_grids << qg
        if not corner.nil?
          qg.corner_label = corner.attribute('rank').value.to_i == 1 ? "V" : "H"
        end

        read_q_rds = lambda do |obj, collection, index_prefix, arr|
          collection.each do |x|
            if x.parent.name == "GridResponseDomain"
              RdsQs.create({
                               question: obj,
                               response_domain: @response_domain_index[
                                   index_prefix +
                                       x
                                           .at_xpath("./r:Label/r:Content")
                                           .content
                               ],
                               code_id: x
                                            .parent
                                            .at_xpath("./d:GridAttachment/d:CellCoordinatesAsDefined/d:SelectDimension[@rank='2']")
                                            .attribute('specificValue')
                                            .value
                                            .to_i
                           })
            else
              obj.send(arr) << @response_domain_index[index_prefix + x.at_xpath("./r:Label/r:Content").content]
            end
          end
        end

        number_of_code_domains_as_axis = 0
        rdcs = question_grid.xpath(".//d:CodeDomain")
        rdcs.each do |rdc|
          if not rdc.parent.name == "GridDimension"
            if rdc.parent.name == "GridResponseDomain"
              RdsQs.create({
                               question: qg,
                               response_domain: @code_list_index[rdc.at_xpath("./r:CodeListReference/r:URN").content].response_domain,
                               code_id: rdc.parent.at_xpath("./d:GridAttachment/d:CellCoordinatesAsDefined/d:SelectDimension[@rank='2']").attribute('specificValue').value.to_i
                           })
            else
              qg.response_domain_codes << @code_list_index[rdc.at_xpath("./r:CodeListReference/r:URN").content].response_domain
            end
          else
            number_of_code_domains_as_axis += 1
          end
        end
        read_q_rds.call(
            qg,
            question_grid.xpath(".//d:NumericDomain"),
            'N',
            'response_domain_numerics'
        )
        read_q_rds.call(
            qg,
            question_grid.xpath(".//d:TextDomain"),
            'T',
            'response_domain_texts'
        )
        read_q_rds.call(
            qg,
            question_grid.xpath(".//d:DateTimeDomain"),
            'D',
            'response_domain_datetimes'
        )

        collection = question_grid.xpath('.//d:CodeDomain | .//d:NumericDomain | .//d:TextDomain | .//d:DateTimeDomain')

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
        instr = question_grid.at_xpath("./d:InterviewerInstructionReference/r:URN")
        if not instr.nil?
          qg.association(:instruction).writer @instruction_index[instr.content]
        end
        qg.save!
      end
    end

    def read_constructs
      seq = doc.xpath("//d:ControlConstructScheme/d:Sequence").first
      cc_seq = @instrument.top_sequence
      cc_seq.label = seq.at_xpath("./d:ConstructName/r:String").content
      @response_unit_index = {}
      read_sequence_children(seq, cc_seq)
    end

    def read_sequence_children(node, parent, branch = nil)
      position_counter = 0
      node.xpath("./d:ControlConstructReference").each do |child_ref|
        position_counter += 1
        urn = child_ref.at_xpath("./r:URN").content
        type = child_ref.at_xpath("./r:TypeOfObject").content
        if type == 'Sequence'
          child = doc.at_xpath("//d:Sequence/r:URN[text()='#{urn}']").parent
          cc_s = CcSequence.new
          @instrument.sequences << cc_s
          cc_s.label = child.at_xpath("./d:ConstructName/r:String").content
          cc_s.position = position_counter
          cc_s.branch = branch
          parent.children << cc_s.cc
          read_sequence_children(child, cc_s)
          cc_s.save!
        elsif type == 'StatementItem'
          child = doc.at_xpath("//d:StatementItem/r:URN[text()='#{urn}']").parent
          cc_s = CcStatement.new
          @instrument.statements << cc_s
          cc_s.label = child.at_xpath("./d:ConstructName/r:String").content
          cc_s.position = position_counter
          cc_s.branch = branch
          cc_s.literal = child.at_xpath("./d:DisplayText/d:LiteralText/d:Text").content
          parent.children << cc_s.cc
          cc_s.save!
        elsif type == 'QuestionConstruct'
          child = doc.at_xpath("//d:QuestionConstruct/r:URN[text()='#{urn}']").parent
          cc_q = CcQuestion.new
          q_urn = child.at_xpath("./r:QuestionReference/r:URN").content
          q_type = child.at_xpath("./r:QuestionReference/r:TypeOfObject").content
          cc_q.question = q_type == 'QuestionItem' ? @question_item_index[q_urn] : @question_grid_index[q_urn]
          ru_val = child.at_xpath("./d:ResponseUnit").content
          if @response_unit_index.has_key? ru_val
            ru = @response_unit_index[ru_val]
          else
            ru = ResponseUnit.new({label: child.at_xpath("./d:ResponseUnit").content})
            @instrument.response_units << ru
            @response_unit_index[ru_val] = ru
          end
          cc_q.response_unit = ru
          @instrument.questions << cc_q
          cc_q.label = child.at_xpath("./d:ConstructName/r:String").content
          cc_q.position = position_counter
          cc_q.branch = branch
          parent.children << cc_q.cc
          cc_q.save!
        elsif type == 'IfThenElse'
          child = doc.at_xpath("//d:IfThenElse/r:URN[text()='#{urn}']").parent
          cc_c = CcCondition.new
          @instrument.conditions << cc_c
          cc_c.label = child.at_xpath("./d:ConstructName/r:String").content
          cc_c.position = position_counter
          cc_c.branch = branch
          cc_c.literal = child.at_xpath("./d:IfCondition/r:Description/r:Content").content
          cc_c.logic = child.at_xpath("./d:IfCondition/r:Command/r:CommandContent").content

          parent.children << cc_c.cc
          cc_c.save!

          sub_sequence = lambda do |search, cc, branch|
            sub_seq = child.at_xpath(search)
            if not sub_seq.nil?
              urn = sub_seq.content
              seq = doc.at_xpath("//d:Sequence/r:URN[text()='#{urn}']").parent
              read_sequence_children seq, cc, branch
            end
          end

          sub_sequence.call './d:ThenConstructReference/r:URN', cc_c, 0
          sub_sequence.call './d:ElseConstructReference/r:URN', cc_c, 1

        elsif type == 'Loop'

          sub_sequence = lambda do |search, cc|
            sub_seq = child.at_xpath(search)
            if not sub_seq.nil?
              urn = sub_seq.content
              seq = doc.at_xpath("//d:Sequence/r:URN[text()='#{urn}']").parent
              read_sequence_children seq, cc
            end
          end

          child = doc.at_xpath("//d:Loop/r:URN[text()='#{urn}']").parent
          cc_l = CcLoop.new
          @instrument.loops << cc_l
          start_node = child.at_xpath("./d:InitialValue/r:Command/r:CommandContent")
          end_node = child.at_xpath("./d:EndValue/r:Command/r:CommandContent")
          while_node = child.at_xpath("./d:LoopWhile/r:Command/r:CommandContent")
          cc_l.label = child.at_xpath("./d:ConstructName/r:String").content
          cc_l.position = position_counter
          cc_l.branch = branch
          if not start_node.nil?
            pieces = start_node.content.split(/\W\D\s/)
            cc_l.loop_var = pieces[0]
            cc_l.start_val = pieces[1]
          end
          if not end_node.nil?
            pieces = end_node.content.split(/\W\D\s/)
            cc_l.end_val = pieces[1]
          end
          if not while_node.nil? then
            cc_l.loop_while = while_node.content
          end
          parent.children << cc_l.cc
          cc_l.save!

          sub_sequence.call './d:ControlConstructReference/r:URN', cc_l

        end
      end

    end

    def self.build_instrument(doc, options= {})
      save = defined?(options[:save]) ? true : options[:save]
      duplicate = defined?(options[:duplicate]) ? :do_nothing : options[:duplicate]

      i = Instrument.new
      i.label = doc.xpath("//d:InstrumentName//r:String").first.content
      urn_pieces = doc.xpath("//r:URN").first.content.split(":")
      i.agency = urn_pieces[2]
      i.prefix = urn_pieces[3].split('-ddi-')[0]
      instruments = Instrument.where({prefix: i.prefix})
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
end
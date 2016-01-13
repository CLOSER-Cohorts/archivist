module XML
  class Importer
    def initialize(filepath)
      @doc = File.open(filepath) { |f| Nokogiri::XML(f) }
      @counters = {}
    end
    
    def parse
      @instrument = Importer.build_instrument @doc
      read_code_lists
      read_instructions
      read_response_domains
      read_questions
      read_constructs
    end
    
    def read_code_lists
      #Read categories first
      categories = @doc.xpath("//l:Category")
      @category_index = {}
      categories.each do |category|
        cat = Category.new({label: category.at_xpath("r:Label/r:Content").content})
        @category_index[category.at_xpath('r:URN').content] = cat
        @instrument.categories << cat
      end
      @counters['categories'] = categories.length
      
      #Read code lists and codes together
      code_lists = @doc.xpath("//l:CodeList")
      @counters['code_lists'] = code_lists.length
      @counters['codes'] = 0
      @code_list_index = {}
      code_lists.each do |code_list|
        cl = CodeList.new({label: code_list.at_xpath("r:Label/r:Content").content})
        @code_list_index[code_list.at_xpath('r:URN').content] = cl
        @instrument.code_lists << cl
        codes = code_list.xpath("l:Code")
        @counters['codes'] += codes.length
        order_counter = 0
        codes.each do |code|
          order_counter += 1
          co = Code.new({value: code.at_xpath("r:Value").content, order: order_counter})
          co.category = @category_index[code.at_xpath("r:CategoryReference/r:URN").content]
          cl.codes << co
        end
      end
      
      #Read response domain code
      @rdcs_created = []
      rdc_urns = @doc.xpath("//d:CodeDomain/r:CodeListReference/r:URN")
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
        @instruction_index[instruction.at_xpath("r:URN").content] = instr
        @instrument.instructions << instr
      end
    end
    
    def read_response_domains
      text_domains = @doc.xpath("//d:TextDomain")
      @counters['response_domain_texts'] = text_domains.length
      @reponse_domain_index ||= {}
      text_domains.each do |text_domain|
        index_label = text_domain.at_xpath("r:Label/r:Content").content
        if not @reponse_domain_index.has_key? "T" + index_label
          rdt = ResponseDomainText.new({label: index_label})
          if not text_domain["maxLength"].nil?
            rdt.maxlen = text_domain["maxLength"].to_i
          end
          @instrument.response_domain_texts << rdt
          @reponse_domain_index["T" + index_label] = rdt
        end
      end
      
      numeric_domains = @doc.xpath("//d:NumericDomain")
      @counters['response_domain_numerics'] = numeric_domains.length
      @reponse_domain_index ||= {}
      numeric_domains.each do |numeric_domain|
        index_label = numeric_domain.at_xpath("r:Label/r:Content").content
        if not @reponse_domain_index.has_key? "N" + index_label
          rdn = ResponseDomainNumeric.new({label: index_label, numeric_type: numeric_domain.at_xpath("r:NumericTypeCode").content})
          min = numeric_domain.at_xpath("r:NumberRange/r:Low")
          max = numeric_domain.at_xpath("r:NumberRange/r:High")
          if not min.nil? then rdn.min = min.content end
          if not max.nil? then rdn.max = max.content end
          @instrument.response_domain_numerics << rdn
          @reponse_domain_index["N" + index_label] = rdn
        end
      end
      
      datetime_domains = @doc.xpath("//d:DateTimeDomain")
      @counters['response_domain_datetimes'] = datetime_domains.length
      @reponse_domain_index ||= {}
      datetime_domains.each do |datetime_domain|
        index_label = datetime_domain.at_xpath("r:Label/r:Content").content
        if not @reponse_domain_index.has_key? "D" + index_label
          rdd = ResponseDomainDatetime.new({label: index_label, datetime_type: datetime_domain.at_xpath("r:DateTypeCode").content})
          format = datetime_domain.at_xpath("r:DateFieldFormat").content
          if format.length > 0 
            rdd.format = format
          end
          @instrument.response_domain_datetimes << rdd
          @reponse_domain_index["D" + index_label] = rdd
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
        rdcs = question_item.xpath(".//d:CodeDomain/r:CodeListReference/r:URN")
        rdcs.each do |rdc|
          qi.response_domain_codes << @code_list_index[rdc.content].response_domain
        end
        rdns = question_item.xpath(".//d:NumericDomain/r:Label/r:Content")
        rdns.each do |rdn|
          qi.response_domain_numerics << @reponse_domain_index['N'+rdn.content]
        end
        rdts = question_item.xpath(".//d:TextDomain/r:Label/r:Content")
        rdts.each do |rdt|
          qi.response_domain_texts << @reponse_domain_index['T'+rdt.content]
        end
        rdds = question_item.xpath(".//d:DateTimeDomain/r:Label/r:Content")
        rdds.each do |rdd|
          qi.response_domain_datetimes << @reponse_domain_index['D'+rdd.content]
        end
        
        #Adding instruction
        instr = question_item.at_xpath("d:InterviewerInstructionReference/r:URN")
        if not instr.nil?
          qi.instruction = @instruction_index[instr.content]
        end
        @instrument.question_items << qi
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
        if not qg_Y.nil?
          qg.vertical_code_list = @code_list_index[qg_Y.content]
        end
        corner = question_grid.at_xpath("d:GridDimension[@displayLabel='true']")
        
        @instrument.question_grids << qg
        if not corner.nil?
          qg.corner_label = corner.attribute('rank').value.to_i == 1 ? "V" : "H"
        end
        rdcs = question_grid.xpath(".//d:CodeDomain")
        rdcs.each do |rdc|
          if not rdc.parent.name == "GridDimension"
            if rdc.parent.name == "GridResponseDomain"
              RdsQs.create({
                question: qg,
                response_domain: @code_list_index[rdc.at_xpath("r:CodeListReference/r:URN").content].response_domain,
                code_id: rdc.parent.at_xpath("d:GridAttachment/d:CellCoordinatesAsDefined/d:SelectDimension[@rank='2']").attribute('specificValue').value.to_i
              })
            else
              qg.response_domain_codes << @code_list_index[rdc.at_xpath("r:CodeListReference/r:URN").content].response_domain
            end
          end
        end
        rdns = question_grid.xpath(".//d:NumericDomain")
        rdns.each do |rdn|
          if rdn.parent.name == "GridResponseDomain"
            RdsQs.create({
              question: qg,
              response_domain: @reponse_domain_index['N'+rdn.at_xpath("r:Label/r:Content").content],
              code_id: rdn.parent.at_xpath("d:GridAttachment/d:CellCoordinatesAsDefined/d:SelectDimension[@rank='2']").attribute('specificValue').value.to_i
            })
          else
            qg.response_domain_numerics << @reponse_domain_index['N'+rdn.at_xpath("r:Label/r:Content").content]
          end
        end
        rdts = question_grid.xpath(".//d:TextDomain")
        rdts.each do |rdt|
          if rdt.parent.name == "GridResponseDomain"
            RdsQs.create({
              question: qg,
              response_domain: @reponse_domain_index['T'+rdt.at_xpath("r:Label/r:Content").content],
              code_id: rdt.parent.at_xpath("d:GridAttachment/d:CellCoordinatesAsDefined/d:SelectDimension[@rank='2']").attribute('specificValue').value.to_i
            })
          else
            qg.response_domain_texts << @reponse_domain_index['T'+rdt.at_xpath("r:Label/r:Content").content]
          end
        end
        rdds = question_grid.xpath(".//d:DateTimeDomain")
        rdds.each do |rdd|
          if rdd.parent.name == "GridResponseDomain"
            RdsQs.create({
              question: qg,
              response_domain: @reponse_domain_index['D'+rdd.at_xpath("r:Label/r:Content").content],
              code_id: rdd.parent.at_xpath("d:GridAttachment/d:CellCoordinatesAsDefined/d:SelectDimension[@rank='2']").attribute('specificValue').value.to_i
            })
          else
            qg.response_domain_datetimes << @reponse_domain_index['D'+rdd.at_xpath("r:Label/r:Content").content]
          end
        end
        
        #Adding instruction
        instr = question_grid.at_xpath("d:InterviewerInstructionReference/r:URN")
        if not instr.nil?
          qg.instruction = @instruction_index[instr.content]
        end
        qg.save!
      end
    end
    
    def read_constructs
      seq = doc.xpath("//d:ControlConstructScheme/d:Sequence").first
      cc_seq = CcSequence.new
      @instrument.sequences << cc_seq
      cc_seq.label = seq.at_xpath("./d:ConstructName/r:String").content
      @response_unit_index = {}
      read_sequence_children(seq, cc_seq)
    end
    
    def read_sequence_children(node, parent)
      node.xpath("./d:ControlConstructReference").each do |child_ref|
        urn = child_ref.at_xpath("./r:URN").content
        type = child_ref.at_xpath("./r:TypeOfObject").content
        if type == 'Sequence'
          child = doc.at_xpath("//d:Sequence/r:URN[text()='#{urn}']").parent
          cc_s = CcSequence.new
          @instrument.sequences << cc_s
          cc_s.label = child.at_xpath("./d:ConstructName/r:String").content
          parent.children << cc_s.cc
          read_sequence_children(child, cc_s)
          cc_s.save!
        elsif type == 'StatementItem'
          child = doc.at_xpath("//d:StatementItem/r:URN[text()='#{urn}']").parent
          cc_s = CcStatement.new
          @instrument.statements << cc_s
          cc_s.label = child.at_xpath("./d:ConstructName/r:String").content
          cc_s.literal = child.at_xpath("./d:DisplayText/d:LiteralText/d:Text").content
          parent.children << cc_s.cc
          cc_s.save!
        elsif type == 'QuestionConstruct'
          child = doc.at_xpath("//d:QuestionConstruct/r:URN[text()='#{urn}']").parent
          cc_q = CcQuestion.new
          q_urn = child.at_xpath("./r:QuestionReference/r:URN").content
          q_type = child.at_xpath("./r:QuestionReference/r:TypeOfObject").content
          cc_q.question = q_type == 'QuestionItem' ?  @question_item_index[q_urn] : @question_grid_index[q_urn]
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
          parent.children << cc_q.cc
          cc_q.save!
        elsif type == 'IfThenElse'
          child = doc.at_xpath("//d:IfThenElse/r:URN[text()='#{urn}']").parent
          cc_c = CcCondition.new
          @instrument.conditions << cc_c
          cc_c.label = child.at_xpath("./d:ConstructName/r:String").content
          c_string = child.at_xpath("./d:IfCondition/r:Command/r:CommandContent").content
          
          #TODO: Protect against no logic
          cc_c.literal = c_string[0, c_string.rindex('[')].strip
          cc_c.logic = c_string[c_string.rindex('[') + 1, c_string.length - c_string.rindex('[') - 2].strip
          parent.children << cc_c.cc
          cc_c.save!
          
          true_branch = child.at_xpath("./d:ThenConstructReference/r:URN")
          if not true_branch.nil?
            then_urn = true_branch.content
            seq = doc.at_xpath("//d:Sequence/r:URN[text()='#{then_urn}']").parent
            read_sequence_children(seq, cc_c)
          end
          
          else_branch = child.at_xpath("./d:ElseConstructReference/r:URN")
          if not else_branch.nil?
            else_urn = else_branch.content
            seq = doc.at_xpath("//d:Sequence/r:URN[text()='#{else_urn}']").parent
            read_sequence_children(seq, cc_c)
          end
          
        elsif type == 'Loop'
          child = doc.at_xpath("//d:Loop/r:URN[text()='#{urn}']").parent
          cc_l = CcLoop.new
          @instrument.loops << cc_l
          start_node = child.at_xpath("./d:InitialValue/r:Command/r:CommandContent")
          end_node = child.at_xpath("./d:EndValue/r:Command/r:CommandContent")
          while_node = child.at_xpath("./d:LoopWhile/r:Command/r:CommandContent")
          cc_l.label = child.at_xpath("./d:ConstructName/r:String").content
          if not start_node.nil?
            pieces = start_node.content.split /\W\D\s/
            cc_l.loop_var = pieces[0]
            cc_l.start_val = pieces[1]
          end
          if not end_node.nil?
            pieces = end_node.content.split /\W\D\s/
            cc_l.end_val = pieces[1]
          end
          if not while_node.nil? then cc_l.loop_while = while_node.content end
          parent.children << cc_l.cc
          cc_l.save!
          
          inner_loop = child.at_xpath("./d:ControlConstructReference/r:URN")
          if not inner_loop.nil?
            inner_loop_urn = inner_loop.content
            seq = doc.at_xpath("//d:Sequence/r:URN[text()='#{inner_loop_urn}']").parent
            read_sequence_children(seq, cc_l)
          end
          
        end
      end
      
    end
    
    def self.build_instrument(doc, options= {})
      save = defined? options[:save] ? true : options[:save]
      duplicate = defined? options[:duplicate] ? :do_nothing : options[:duplicate]
      
      i = Instrument.new
      i.label = doc.xpath("//d:InstrumentName//r:String").first.content
      urn_pieces = doc.xpath("//r:URN").first.content.split(":")
      i.agency = urn_pieces[2]
      instruments = Instrument.where({label: i.label, agency: i.agency})
      if instruments.length > 0
        Rails.logger.info 'Duplicate instrument(s) found while importing XML.'
        if duplicate == :do_nothing
          Rails.logger.info 'Aborting XML import. Consider passing a duplicate option to importer.'
          return
        else
          if duplicate == :update || duplicate == :replace
          if instruments.length == 1
            if duplicate == :update
              i = instruments.first
            else
              instruments.first.destroy
            end
          else
            Rails.logger.error 'Aborting XML import. Cannot update or replace instrument as multiple duplicates found.'
            return
          end 
        end
        end
      end
      i.version = "1.0"
      i.prefix = urn_pieces[3].split('-ddi-')[0]
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
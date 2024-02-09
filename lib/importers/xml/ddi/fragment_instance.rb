module Importers::XML::DDI
  class FragmentInstance

    attr_accessor :questions, :errors

    def initialize(xml_fragment, instrument)
      @xml_fragment = xml_fragment
      @node = Nokogiri(xml_fragment)
      @node = @node.remove_namespaces!
      @instrument = instrument
      @urn_to_object_mapping = {}
      self.questions = []
      self.errors = []
    end

    def valid?
      scan_urn_mappings_for_errors
      errors.empty?
    end

    def scan_urn_mappings_for_errors
      @urn_to_object_mapping.values.select{|r| r.errors.present? }.each_with_index do | record, i |
        errors << "#{i+1}: #{record.errors.full_messages.to_sentence}"
      end
      errors.uniq!
    end

    def process
      ActiveRecord::Base.transaction do
        parsed_fragment = parse
        raise ActiveRecord::Rollback unless valid?
        create_categories(parsed_fragment[:categories])
        raise ActiveRecord::Rollback unless valid?
        create_code_lists(parsed_fragment[:code_lists])
        raise ActiveRecord::Rollback unless valid?
        create_instructions(parsed_fragment[:instructions])
        raise ActiveRecord::Rollback unless valid?
        create_question_items(parsed_fragment[:question_items])
        raise ActiveRecord::Rollback unless valid?
        parsed_fragment
      end
    end

    def create_question_items(question_items=[])
      question_items.each do | question_item_hash |
        urn = question_item_hash.delete(:urn)
        parsed_urn = parse_urn(urn)
        response_domains = question_item_hash.delete(:response_domains)
        if @instrument.prefix != parsed_urn[:instrument_prefix]
          question_item = @instrument.question_items.create(question_item_hash)
        else
          question_item = @instrument.question_items.create(question_item_hash)
        end

        @urn_to_object_mapping[urn] = question_item
        question_item.rds_qs.delete_all
        response_domains.each do | response_domain_hash |
          rd_order = response_domain_hash.delete(:rd_order)
          response_domain = create_response_domain(response_domain_hash)
          if response_domain.errors.present?
            errors << "#{response_domain.errors.full_messages.to_sentence}"
            return
          end
          question_item.rds_qs.create(question: question_item, response_domain: response_domain, instrument: @instrument, rd_order: rd_order)
        end
        questions.push(question_item)
      end
    end

    def create_response_domain(response_domain_hash)
      if response_domain_hash[:response_domain_type] == 'ResponseDomainCode'
        urn = response_domain_hash.delete(:urn)
        code_list_urn = response_domain_hash.delete(:code_list_urn)
        response_domain_hash[:code_list] = @urn_to_object_mapping[code_list_urn]
      end
      type = response_domain_hash[:response_domain_type].pluralize.underscore
      @instrument.send(type).create(response_domain_hash)
    end

    def create_instructions(instructions=[])
      instructions.each do | instruction_hash |
        urn = instruction_hash.delete(:urn)
        parsed_urn = parse_urn(urn)
        if @instrument.prefix != parsed_urn[:instrument_prefix]
          @urn_to_object_mapping[urn] = @instrument.instructions.create(instruction_hash)
        else
          existing_instruction = @instrument.instructions.find_by(id: parsed_urn[:id])
          if existing_instruction
            @urn_to_object_mapping[urn] = existing_instruction.update(instruction_hash)
          else
            @urn_to_object_mapping[urn] = @instrument.instructions.create(instruction_hash)
          end
        end
      end
    end

    def create_categories(categories=[])
      categories.reverse.each do | category_hash |
        urn = category_hash.delete(:urn)
        parsed_urn = parse_urn(urn)
        if @instrument.prefix != parsed_urn[:instrument_prefix]
          existing_category = @instrument.categories.find_by(label: category_hash[:label])
          if existing_category
            existing_category.update(category_hash)
            @urn_to_object_mapping[urn] = existing_category
          else
            @urn_to_object_mapping[urn] = @instrument.categories.create(category_hash)
          end
        else
          existing_category = @instrument.categories.find_by(id: parsed_urn[:id]) || @instrument.categories.find_by(label: category_hash[:label])

          if existing_category
            existing_category.update(category_hash)
            @urn_to_object_mapping[urn] = existing_category
          else
            @urn_to_object_mapping[urn] = @instrument.categories.create(category_hash)
          end
        end
      end
    end

    def create_code_lists(code_lists=[])
      code_lists.reverse.each do | code_list_hash |
        urn = code_list_hash.delete(:urn)
        codes = code_list_hash.delete(:codes)
        parsed_urn = parse_urn(urn)
        if @instrument.prefix != parsed_urn[:instrument_prefix]
          @urn_to_object_mapping[urn] = @instrument.code_lists.create(code_list_hash)
        else
          existing_code_list = @instrument.code_lists.find_by(id: parsed_urn[:id])
          if existing_code_list
            existing_code_list.update(code_list_hash)
            @urn_to_object_mapping[urn] = existing_code_list
          else
            @urn_to_object_mapping[urn] = @instrument.code_lists.create(code_list_hash)
          end
        end
        create_codes(codes, @urn_to_object_mapping[urn])
      end
    end

    def create_codes(codes, code_list)
      codes.reverse.each do | code_hash |
        code_hash[:code_list_id] = code_list.id
        urn = code_hash.delete(:urn)
        category_urn = code_hash.delete(:category_urn)
        code_hash[:category] = @urn_to_object_mapping[category_urn]
        parsed_urn = parse_urn(urn)
        if @instrument.prefix != parsed_urn[:instrument_prefix]
          @urn_to_object_mapping[urn] = @instrument.codes.create(code_hash)
        else
          existing_code = @instrument.codes.find_by(id: parsed_urn[:id])
          if existing_code
            existing_code.update(code_hash)
            @urn_to_object_mapping[urn] = existing_code
          else
            @urn_to_object_mapping[urn] = @instrument.codes.create(code_hash)
          end
        end
      end
    end

    def parse
      hash = {}
      matchers = { question_item: './QuestionItem', category: './Category', code_list: './CodeList', instruction: './Instruction'}

      @node.xpath('//Fragment').each do | n |
        matchers.each do | sym, xpath_reference |
          child_nodes = n.xpath(xpath_reference)
          hash[sym.to_s.pluralize.to_sym] = [] unless hash[sym.to_s.pluralize.to_sym]
          hash[sym.to_s.pluralize.to_sym] << send("parse_#{sym}", child_nodes) if child_nodes.present?
        end
      end
      if hash.empty?
        errors << 'No XML Fragments found'
      end
      hash
    end

    def parse_question_item(node)
      {
        urn: node.at_xpath('./URN').try(:content),
        label: node.at_xpath('./QuestionItemName/String').try(:content),
        literal: node.at_xpath('./QuestionText/LiteralText/Text').try(:content),
        response_domains: parse_response_domains(node)
      }
    end

    def parse_category(node)
      {
        urn: node.at_xpath('./URN').try(:content),
        label: node.at_xpath('./Label/Content').try(:content)
      }
    end

    def parse_code_list(node)
      {
        urn: node.at_xpath('./URN').try(:content),
        label: node.at_xpath('./Label/Content').try(:content),
        codes: node.xpath('./Code').map{|code_node| parse_code(code_node)}
      }
    end

    def parse_code(node)
      {
        urn: node.at_xpath('./URN').try(:content),
        value: node.at_xpath('./Value').try(:content),
        category_urn: node.at_xpath('./CategoryReference/URN').try(:content)
      }
    end

    def parse_response_domains(node)
      node.xpath('//CodeDomain|//DateTimeDomain|//NumericDomain|//TextDomain').map.with_index do | rd_node, i |
        hash =  case rd_node.name
                when 'CodeDomain'
                  parse_response_domain_code(rd_node)
                when 'DateTimeDomain'
                  parse_response_domain_date_time(rd_node)
                when 'NumericDomain'
                  parse_response_domain_numeric(rd_node)
                when 'TextDomain'
                  parse_response_domain_text(rd_node)
                end
        hash.merge(rd_order: i +1 )
      end
    end

    def parse_response_domain_code(node)
      {
        response_domain_type: "ResponseDomainCode",
        code_list_urn: node.at_xpath('./CodeListReference/URN').try(:content),
        min_responses: node.at_xpath('./ResponseCardinality/@minimumResponses').try(:value),
        max_responses: node.at_xpath('./ResponseCardinality/@maximumResponses').try(:value)
      }
    end

    def parse_response_domain_date_time(node)
      {
        response_domain_type: "ResponseDomainDatetime",
        datetime_type: node.at_xpath('./DateTypeCode').try(:content)
      }
    end

    def parse_response_domain_numeric(node)
      {
        response_domain_type: "ResponseDomainNumeric",
        min: node.at_xpath('./NumberRange/Low').try(:content),
        max: node.at_xpath('./NumberRange/High').try(:content),
        numeric_type: node.at_xpath('./NumericTypeCode').try(:content),
        label: node.at_xpath('./Label/Content').try(:content)
      }
    end

    def parse_response_domain_text(node)
      {
        response_domain_type: "ResponseDomainText",
        label: node.at_xpath('./Label/Content').try(:content),
        maxlen: node.at_xpath('@maxLength').try(:value)
      }
    end

    def parse_instruction(node)
      {
        urn: node.at_xpath('./URN').try(:content),
        text: node.at_xpath('./InstructionText/LiteralText/Text').try(:content)
      }
    end

    def parse_urn(urn)
      urn.match(/urn:ddi:(?<instrument_agency>.*):(?<instrument_prefix>.*)-(?<type>.*)-(?<id>.*):(.*)/)
    end
  end
end

module Importers::XML::DDI
  class FragmentInstance
    def initialize(xml_fragment, instrument)
      @xml_fragment = xml_fragment
      @node = Nokogiri(xml_fragment)
      @node = @node.remove_namespaces!
      @instrument = instrument
      @urn_to_object_mapping = {}
    end

    def process
      parsed_fragment = parse
      create_categories(parsed_fragment[:categories])
      create_code_lists(parsed_fragment[:code_lists])
      create_instructions(parsed_fragment[:instructions])
      parsed_fragment
    end

    def create_instructions(instructions)
      instructions.each do | instruction_hash |
        urn = instruction_hash.delete(:urn)
        parsed_urn = parse_urn(urn)
        if @instrument.prefix != parsed_urn[:instrument_prefix]
          @urn_to_object_mapping[urn] = @instrument.instructions.create(instruction_hash)
        else
          existing_instruction = @instrument.instructions.find_by(id: parsed_urn[:instrument_prefix])
          if existing_instruction
            @urn_to_object_mapping[urn] = existing_instruction.update_attributes(instruction_hash)
          else
            @urn_to_object_mapping[urn] = @instrument.instructions.create(instruction_hash)
          end
        end
      end
    end

    def create_categories(categories)
      categories.each do | category_hash |
        urn = category_hash.delete(:urn)
        parsed_urn = parse_urn(urn)
        if @instrument.prefix != parsed_urn[:instrument_prefix]
          @urn_to_object_mapping[urn] = @instrument.categories.create(category_hash)
        else
          existing_category = @instrument.categories.find_by(id: parsed_urn[:instrument_prefix])
          if existing_category
            @urn_to_object_mapping[urn] = existing_category.update_attributes(category_hash)
          else
            @urn_to_object_mapping[urn] = @instrument.categories.create(category_hash)
          end
        end
      end
    end

    def create_code_lists(code_lists)
      code_lists.each do | code_list_hash |
        urn = code_list_hash.delete(:urn)
        codes = code_list_hash.delete(:codes)
        parsed_urn = parse_urn(urn)
        if @instrument.prefix != parsed_urn[:instrument_prefix]
          @urn_to_object_mapping[urn] = @instrument.code_lists.create(code_list_hash)
        else
          existing_code_list = @instrument.code_lists.find_by(id: parsed_urn[:instrument_prefix])
          if existing_code_list
            @urn_to_object_mapping[urn] = existing_code_list.update_attributes(code_list_hash)
          else
            @urn_to_object_mapping[urn] = @instrument.code_lists.create(code_list_hash)
          end
        end
        create_codes(codes, @urn_to_object_mapping[urn])
      end
    end

    def create_codes(codes, code_list)
      codes.each do | code_hash |
        code_hash[:code_list_id] = code_list.id
        urn = code_hash.delete(:urn)
        category_urn = code_hash.delete(:category_urn)
        code_hash[:category] = @urn_to_object_mapping[category_urn]
        parsed_urn = parse_urn(urn)
        if @instrument.prefix != parsed_urn[:instrument_prefix]
          @urn_to_object_mapping[urn] = @instrument.codes.create!(code_hash)
        else
          existing_code = @instrument.codes.find_by(id: parsed_urn[:instrument_prefix])
          if existing_code
            @urn_to_object_mapping[urn] = existing_code.update_attributes(code_hash)
          else
            @urn_to_object_mapping[urn] = @instrument.codes.create!(code_hash)
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
      hash
    end

    def parse_question_item(node)
      {
        urn: node.at_xpath('./URN').try(:content),
        name: node.at_xpath('./QuestionItemName/String').try(:content),
        text: node.at_xpath('./QuestionText/LiteralText/Text').try(:content),
        response_domain_codes: node.xpath('//CodeDomain').map{|rd_node| parse_response_domain_code(rd_node)},
        response_domain_datetimes: node.xpath('//DateTimeDomain').map{|rd_node| parse_response_domain_date_time(rd_node)},
        response_domain_numerics: node.xpath('//NumericDomain').map{|rd_node| parse_response_domain_numeric(rd_node)},
        response_domain_texts: node.xpath('//TextDomain').map{|rd_node| parse_response_domain_text(rd_node)}
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

    def parse_response_domain_code(node)
      {
        urn: node.at_xpath('./CodeListReference/URN').try(:content),
        response_cardinality: {
          min: node.at_xpath('./ResponseCardinality/@minimumResponses').try(:value),
          max: node.at_xpath('./ResponseCardinality/@maximumResponses').try(:value)
        }
      }
    end

    def parse_response_domain_date_time(node)
      {
        datetime_type: node.at_xpath('./DateTypeCode').try(:content)
      }
    end

    def parse_response_domain_numeric(node)
      {
        min: node.at_xpath('./NumberRange/Low').try(:content),
        max: node.at_xpath('./NumberRange/High').try(:content),
        numeric_type: node.at_xpath('./NumericTypeCode').try(:content),
        label: node.at_xpath('./Label/Content').try(:content)
      }
    end

    def parse_response_domain_text(node)
      {
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

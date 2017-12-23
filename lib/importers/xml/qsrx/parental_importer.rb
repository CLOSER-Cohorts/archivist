module Importers::XML::QSRX
  class ParentalImporter
    @@statement_counter = 0
    @@condition_counter = 0

    def initialize(instrument)
      @instrument = instrument
    end

    protected
    def method_missing(m, *args, &block)
      m.slice(0..4)
      Rails.logger.warn "QSRX importer does not support #{m} tags. It will be skipped."
      nil
    end

    def read_children(parent)
      @node.xpath('./specification_elements/*').each do |child_node|
        parent.children << read_element(child_node)
      end
      parent
    end

    def read_dcomment(node)
      return nil if node.content.nil?
      @@statement_counter += 1
      @instrument.cc_statements.new(
        label: 's_' + @@statement_counter.to_s,
        literal: node.content
      )
    end

    def read_element(node)
      send("read_#{node.name}", node)
    end

    def read_branch(node)
      branch_importer = Importers::XML::QSRX::Branch.new @instrument
      branch_importer.XML_node(node)
    end

    def read_loop(node)
      loop_importer = Importers::XML::QSRX::Loop.new @instrument
      loop_importer.XML_node(node)
    end

    def read_question(node)
      question_item = @instrument.question_items.new(
          label: node['name'],
          literal: node.at_xpath('./qt_properties/label')&.content
      )

      text_node = node.at_xpath('./qt_properties/text')
      question_item.literal = text_node.content unless text_node.nil?

      return if question_item.literal.nil?

      instruction_text = node.at_xpath('./qt_properties/help')&.content
      instruction_text = node.at_xpath('./qt_properties/iiposttext')&.content if instruction_text.nil?
      question_item.instruction = instruction_text unless instruction_text.nil?

      response_domain = nil
      case node['type']
      when 'number'
        response_domain = @instrument.response_domain_numerics.new(
          label: node['name'],
          numeric_type: node.at_xpath('./qt_properties/decimals')&.content&.to_i == 0 ? 'Integer' : 'Float',
        )
        range_node = node.at_xpath('./qt_properties/range')
        unless range_node.nil?
          response_domain.min = range_node['min']
          response_domain.max = range_node['max']
        end

        when 'text','string'
          response_domain = @instrument.response_domain_texts.new(
              label: node['name'],
              maxlen: node.at_xpath('./qt_properties/length')&.content,
          )
        when 'date', 'time'
          response_domain = @instrument.response_domain_datetimes.new(
              label: node['name'],
              datetime_type: node['type'].capitalize
          )
        when 'choice', 'multichoice'
          code_list = @instrument.code_lists.new(
              label: node['name'],
          )
          node.xpath('./qt_properties/options/option').each_with_index do |option, index|
            code = Code.new
            code.value = option['value'].to_i
            code.order = index + 1
            code.set_label(option.at_xpath('./text')&.content, @instrument)
            code_list.codes << code
          end
          code_list.response_domain = true
          response_domain = code_list.response_domain
          response_domain.max_responses = code_list.codes.count
      end

      response_domain.save!
      question_item.save!

      RdsQs.create(
        question: question_item,
        response_domain: response_domain,
        instrument_id: @instrument.id,
        rd_order: 1
      )

      @instrument.cc_questions.new(
          label: node['name'],
          question: question_item,
          response_unit: @instrument.response_units.first
      )
    end
  end
end

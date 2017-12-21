module Importers::XML::QSRX
  class ParentalImporter
    def initialize(instrument)
      @instrument = instrument
    end

    protected
    def method_missing(m, *args, &block)
      m.slice(0..4)
      Rails.logger.warn "QSRX importer does not support #{m} tags. It will be skipped."
    end

    def read_children(parent)
      @node.xpath('./specification_elements/*').each do |child_node|
        parent.children << read_element(child_node)
      end
      parent
    end

    def read_dcomment(node)
      @instrument.cc_statements.new(
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

      instruction_text = node.at_xpath('./qt_properties/help')&.content
      instruction_text = node.at_xpath('./qt_properties/iiposttext')&.content if instruction_text.nil?
      unless instruction_text.nil?
        question_item.instruction = instruction_text
      end

      case node['number']
      when 'number'
        response_domain = @instrument.response_domain_numbers.new(
          label: node['name'],
          numeric_type: node.at_xpath('./qt_properties/decimals')&.content&.to_i == 0 ? 'Integer' : 'Float',
        )
        range_node = node.at_xpath('./qt_properties/range')
        unless range_node.nil?
          response_domain.min = range_node['min']
          response_domain.max = range_node['max']
        end

      end

      response_domain.save!
      question_item.save!
      question_item.add_rds [response_domain]

      @instrument.cc_questions.new(
          label: node['name'],
          question: question_item,
          response_unit: @instrument.response_units.first
      )
    end
  end
end

module Importers::XML::QSRX
  class Module < ParentalImporter
    def initialize(instrument)
      @instrument = instrument
    end

    def XML_node(node)
      @node = node
      sequence = @instrument.cc_sequences.new(
          label: @node.at_xpath('./context')&.content,
          literal: @node.at_xpath('./rm_properties/label')
      )
      sequence.save!

      read_children(sequence)
    end

    def read_dcomment(node)
      @instrument.cc_statements.new(
        literal: node.content
      )
    end

    def read_question(node)
      question_item = @instrument.question_items.new(
          label: node['name'],
          literal: node.at_xpath('./qt_properties/label')&.content
      )

      instruction_text = node.at_xpath('./qt_properties/iiposttext')&.content
      unless instruction_text.nil?
        question_item.instruction = instruction_text
      end

      question_item.save!

      @instrument.cc_questions.new(
          label: node['name'],
          question: question_item,
          response_unit: @instrument.response_units.first
      )
    end
  end
end
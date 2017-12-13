module Importers::XML::QSRX
  class Module
    def initialize(instrument)
      @instrument = instrument
    end

    def XML_node(node)
      sequence = @instrument.cc_sequences.new(
          label: node.at_xpath('./context')&.content,
          literal: node.at_xpath('./rm_properties/label')
      )
      sequence.save!

      read_children(sequence)
    end

    def read_dcomment(node)
      statement = @instrument.cc_statements.new(
        literal: node.content
      )
    end

    def read_question(node)
      case node['type']
        when 'time'
        when 'choice'
        when 'number'
        when 'string'
        when 'multichoice'
        when 'date'
        when 'text'

      end
    end
  end
end
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

    def read_dcomment
      statement = @instrument.cc_statements.new(

      )
    end
  end
end
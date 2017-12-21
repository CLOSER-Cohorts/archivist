module Importers::XML::QSRX
  class Module < ParentalImporter
    def XML_node(node)
      @node = node
      sequence = @instrument.cc_sequences.new(
          label: @node.at_xpath('./context')&.content,
          literal: @node.at_xpath('./rm_properties/label')
      )
      sequence.save!

      read_children(sequence)
    end
  end
end

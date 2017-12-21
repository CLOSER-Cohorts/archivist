module Importers::XML::QSRX
  class Loop < ParentalImporter
    def XML_node(node)
      @node = node
      loop = @instrument.cc_loops.new(
          label: @node.at_xpath('./context')&.content
      )
      loop.save!

      read_children(loop)
    end
  end
end

module Importers::XML::QSRX
  class Branch < ParentalImporter
    @counter = 0
    def XML_node(node)
      @node = node.at_xpath('./if')
      @counter += 1
      condition = @instrument.cc_conditions.new(
          label: @counter.to_s,
          literal: @node.at_xpath('./condition')&.content,
          logic: @node.at_xpath('./sd_properties/label')&.content
      )
      condition.save!

      read_children(condition)
    end
  end
end

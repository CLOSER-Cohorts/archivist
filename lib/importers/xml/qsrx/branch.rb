module Importers::XML::QSRX
  class Branch < ParentalImporter
    def XML_node(node)
      @node = node.at_xpath('./if')
      @@condition_counter += 1
      condition = @instrument.cc_conditions.new(
          label: 'c_' + @@condition_counter.to_s,
          literal: @node.at_xpath('./condition')&.content.to_s,
          logic: @node.at_xpath('./sd_properties/label')&.content
      )
      condition.save!

      read_children(condition)
    end
  end
end

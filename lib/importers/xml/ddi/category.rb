module Importers::XML::DDI
  class Category < DdiImporterBase
    def initialize(instrument)
      @instrument = instrument
    end

    def XML_node(node)
      begin
        cat = ::Category.new label: node.at_xpath('./Label/Content').content
      rescue
        cat = ::Category.new label: ''
      end
      cat.instrument_id = @instrument.id
      cat.save!
      cat.add_urn extract_urn_identifier node
    end

    def XML_scheme(scheme)
      scheme.xpath('./Category').each do |category_node|
        XML_node category_node
      end
    end
  end
end
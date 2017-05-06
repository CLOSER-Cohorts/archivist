module Importers::XML::DDI
  class Category < DdiImporterBase
    def initialize(instrument)
      @instrument = instrument
    end

    def XML_node(node)
      begin
        cat = Category.new label: category.at_xpath('./Label/Content').content
      rescue
        cat = Category.new label: ''
      end
      @instrument.categories << cat
      cat.add_urn = extract_urn_identifier category
    end

    def XML_scheme(scheme)
      scheme.xpath('.//Category').each do |category_node|
        XML_node category_node
      end
    end
  end
end
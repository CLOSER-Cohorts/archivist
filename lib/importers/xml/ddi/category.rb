module Importers::XML::DDI
  class Category
    def initialize(instrument)
      @instrument = instrument
    end

    def XML_node(node)
      begin
        cat = Category.new label: category.at_xpath('./Label/Content').content
      rescue
        cat = Category.new label: ''
      end
      Reference[category] = cat
      @instrument.categories << cat
    end

    def XML_scheme(scheme)

    end
  end
end
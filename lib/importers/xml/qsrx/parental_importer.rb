module Importers::XML::QSRX
  class ParentalImporter
    protected
    def read_children
      @node.xpath('./specification_elements/*').each(&:read_element)
    end

    def read_element(node)
      send("read_#{node.name}", node)
    end

    def method_missing(m, *args, &block)
      m.slice!(0..4)
      Rails.logger.warn "QSRX importer does not support #{m} tags. It will be skipped."
    end
  end
end
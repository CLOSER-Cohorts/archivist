module Importers::XML::QSRX
  class Specification < ParentalImporter

    def initialize(node)
      @node = node
    end

    def import_instrument(agency, prefix, study='')
      @instrument = Instrument.new prefix: prefix, agency: agency, study: study, version: '1'
      @instrument.label @node.at_xpath('./sd_properties/label')&.content
      @instrument.save!

      @module_importer = Importers::XML::QSRX::Module.new @instrument

      read_children(@instrument.top_sequence)
    end

    def read_module(node)
      @module_importer.XML_node(node)
    end
  end
end
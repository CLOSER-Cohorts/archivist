module Importers::XML::QSRX
  class Specification < ParentalImporter

    def initialize(thing)
      if thing.is_a? String
        @doc = open(thing) { |f| Nokogiri::XML(f) }
      else
        document = Document.find thing
        @doc = Nokogiri::XML document.file_contents
      end
      @doc.remove_namespaces!
      @node = @doc.at_xpath('./qsrx/specification')
    end

    def import_instrument(agency, prefix, study='')
      @instrument = Instrument.new prefix: prefix, agency: agency, study: study, version: '1'
      @instrument.label = @node.at_xpath('./sd_properties/label')&.content
      @instrument.save!

      @instrument.response_units.create(label: 'Cohort/sample member')

      @module_importer = Importers::XML::QSRX::Module.new @instrument

      read_children(@instrument.top_sequence)
    end

    def read_module(node)
      @module_importer.XML_node(node)
    end
  end
end
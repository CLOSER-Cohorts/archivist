module Exporters::XML::DDI
  # Static class to wrap DDI node exports into correctly formatted
  # fragments
  module Fragment
    class << self
      # Exports DDI 3.2 Fragment
      #
      # @param [DdiExporterBase] exporter_klass DDI node exporter class to use
      # @param [Exportable] obj Item for exporting
      # @return [String] DDI 3.2 fragment
      def export_3_2 (exporter_klass, obj)
        doc = Nokogiri::XML '<Fragment></Fragment>'
        datetimestring = Time.now.strftime '%Y-%m-%dT%H:%M:%S%:z'

        doc.root['xmlns:d'] = 'ddi:datacollection:3_2'
        doc.root['xmlns:g'] = 'ddi:group:3_2'
        doc.root['xmlns:l'] = 'ddi:logicalproduct:3_2'
        doc.root['xmlns:r'] = 'ddi:reusable:3_2'
        doc.root['xmlns'] = 'ddi:instance:3_2'

        exp = exporter_klass.new doc
        doc.root.add_child exp.V3_2(obj)
        doc.root.first_element_child['versionDate'] = datetimestring
        doc.to_xml(&:no_empty_tags)
      end
    end
  end
end
module Exporters::XML::DDI
  module Fragment
    class << self
      def export_3_2 (exporter_klass, obj)
        doc = Nokogiri::XML '<Fragment></Fragment>'
        datetimestring = Time.now.strftime '%Y-%m-%dT%H:%M:%S%:z'
        doc.root['versionDate'] = datetimestring
        doc.root['xmlns:d'] = 'ddi:datacollection:3_2'
        doc.root['xmlns:ddi'] = 'ddi:instance:3_2'
        doc.root['xmlns:g'] = 'ddi:group:3_2'
        doc.root['xmlns:l'] = 'ddi:logicalproduct:3_2'
        doc.root['xmlns:r'] = 'ddi:reusable:3_2'


        exp = exporter_klass.new doc
        doc.root.add_child exp.V3_2(obj)
        doc.to_xml &:no_empty_tags
      end
    end
  end
end
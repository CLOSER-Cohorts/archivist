module Importers::XML::DDI
  class DdiImporterBase
    include ::Importers::Loggable
    private
    def compose_urn(agency_node, id_node, version_node)
      'urn:ddi:%{agency}:%{id}:%{version}' % {
          agency:   agency_node&.content,
          id:       id_node&.content,
          version:  version_node&.content
      }
    end

    def extract_urn_identifier(xml_node)
      return unless xml_node
      urn = xml_node&.at_xpath('./URN')&.content
      if urn.nil?
        agency_node = xml_node.at_xpath('./Agency')
        id_node = xml_node.at_xpath('./ID')
        version_node = xml_node.at_xpath('./Version')
        urn = compose_urn(agency_node, id_node, version_node)
      end
      urn
    end
  end
end

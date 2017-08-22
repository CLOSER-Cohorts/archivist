module Exporters::XML::DDI
  # Base DDI Exporter abstract class
  #
  # This class provides useful methods for all versions of DDI
  # XML export.
  #
  # Instance variable @urn_prefix can be set in derived exporters to overload the default functionality
  class DdiExporterBase
    # Sets the XML document for exporting to
    #
    # @param [Nokogiri::XML::Document] doc Target XML document for exporting
    def initialize(doc)
      @doc = doc
    end

    private  # Private methods
    # Creates a standard URN for the given object
    #
    # @param [Exportable] obj Item for exporting
    # @param [String] urn_type (Optional) Specify a different URN_TYPE
    # @return [Nokogiri::XML::Node] New URN node
    def create_urn_node(obj, urn_type = nil)
      urn = Nokogiri::XML::Node.new 'r:URN', @doc
      urn.content = obj.urn @urn_prefix, urn_type
      urn
    end

    # Creates a standard URN-based reference for the given object
    #
    # @param [String] node_name Name of reference node e.g. VariableReference
    # @param [Exportable] obj Item for exporting
    # @return [Nokogiri::XML::Node] New reference node
    def create_reference_string(node_name, obj)
      ref = Nokogiri::XML::Node.new node_name, @doc
      ref.add_child '<r:URN>%{urn}</r:URN><r:TypeOfObject>%{type}</r:TypeOfObject>' %
                        {urn: obj.urn(@urn_prefix), type: obj.class::TYPE}
      ref
    end
  end
end
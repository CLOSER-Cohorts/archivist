module Exporters::XML::DDI
  class DdiExporterBase
    private
    def create_urn_node(obj)
      urn = Nokogiri::XML::Node.new 'r:URN', @doc
      urn.content = obj.urn @urn_prefix
      urn
    end

    def create_reference_string(node_name, obj)
      ref = Nokogiri::XML::Node.new node_name, @doc
      ref.add_child '<r:URN>%{urn}</r:URN><r:TypeOfObject>%{type}</r:TypeOfObject>' %
                        {urn: obj.urn(@urn_prefix), type: obj.class::TYPE}
      ref
    end
  end
end
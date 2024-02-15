module Importers::XML::DDI
  class Instruction < DdiImporterBase
    def initialize(instrument)
      @instrument = instrument
    end

    def XML_node(node)
      instruction = ::Instruction.new({urn: extract_urn_identifier(node), text: node.at_xpath('./InstructionText/LiteralText/Text').content})
      begin
        @instrument.instructions << instruction
      rescue ActiveRecord::RecordInvalid
        raise Importers::XML::DDI::ValidationError.new(node.to_xml, instruction)
      end
      instruction.add_urn extract_urn_identifier node
    end

    def XML_scheme(scheme)
      scheme.xpath('./Instruction').each do |instruction_node|
        XML_node instruction_node
      end
    end
  end
end
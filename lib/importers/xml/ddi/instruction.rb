module Importers::XML::DDI
  class Instruction < DdiImporterBase
    def initialize(instrument)
      @instrument = instrument
    end

    def XML_node(node)
      instruction = ::Instruction.new({text: node.at_xpath('./InstructionText/LiteralText/Text').content})

      @instrument.instructions << instruction
      instruction.add_urn extract_urn_identifier node
    end

    def XML_scheme(scheme)
      scheme.xpath('./Instruction').each do |instruction_node|
        XML_node instruction_node
      end
    end
  end
end
module Exporters::XML::DDI
  class Instruction < DdiExporterBase
    def V3_2(instr_id)
      if instr_id.is_a? ::Instruction
        instr = instr_id
      else
        instr = ::Instruction.find instr_id
      end

      i = Nokogiri::XML::Node.new 'd:Instruction', @doc
      urn = create_urn_node instr
      i.add_child urn
      urn.add_next_sibling "<d:InstructionText audienceLanguage=\"en-GB\"><d:LiteralText><d:Text>%{literal}</d:Text></d:LiteralText></d:InstructionText>" % {
          literal: CGI::escapeHTML(instr.text.to_s)
      }
      i
    end
  end
end
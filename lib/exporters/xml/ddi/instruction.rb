module Exporters::XML::DDI
  # DDI 3.2 XML Exporter for {::Instruction}
  #
  # {::Instruction} is a direct alias of DDI 3.2 InterviewerInstruction.
  #
  # === Example
  #   doc = Nokogiri::XML::Document.new
  #   instruc = Instruction.first
  #   exporter = Exporters::XML::DDI::Instruction.new doc
  #   xml_node = exporter.V3_2(instruc)
  #
  # @see ::Instruction
  class Instruction < DdiExporterBase
    # Exports the {::Instruction} in DDI 3.2
    #
    # Create a single XML node as an export of a single {::Instruction}.
    # In order to be valid DDI, this node then needs to be wrapped
    # either in a InterviewerInstructionScheme or a Fragment.
    #
    # @param [::Instruction|Integer] instr_id Either the Instruction or Instruction ID for exporting
    # @return [Nokogiri::XML::Node] New XML node
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
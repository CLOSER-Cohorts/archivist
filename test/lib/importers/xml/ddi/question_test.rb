require 'test_helper'
require 'active_support/core_ext/hash/conversions'

class Importers::XML::DDI::QuestionTest < ActiveSupport::TestCase

  describe ".question_item_node" do
    it "should record response cardinality for code list" do
      instrument = FactoryBot.create(:instrument, study: 'uk.alspac')
      question_item = FactoryBot.create(:question_item, instrument: instrument)
      code_list = FactoryBot.create(:code_list, instrument: instrument)
      instruction = FactoryBot.create(:instruction, instrument: instrument)
      code_list.add_urn(code_list.urn)
      text = %Q|
      <QuestionItem>
        <URN>#{question_item.urn}</URN>
        <UserAttributePair>
          <AttributeKey>extension:Label</AttributeKey>
          <AttributeValue>{"en-GB":"A1 a"}</AttributeValue>
        </UserAttributePair>
        <QuestionItemName>
          <String xml:lang="en-GB">qi_A1_a</String>
        </QuestionItemName>
        <QuestionText audienceLanguage="en-GB">
          <LiteralText>
            <Text>The school gives high priority to raising pupils' standards of achievement</Text>
          </LiteralText>
        </QuestionText>
        <CodeDomain>
          <CodeListReference>
            <URN>#{code_list.urn}</URN>
            <TypeOfObject>CodeList</TypeOfObject>
          </CodeListReference>
          <ResponseCardinality minimumResponses="1" maximumResponses="1"></ResponseCardinality>
        </CodeDomain>
        <InterviewerInstructionReference>
          <URN>#{instruction.urn}</URN>
          <TypeOfObject>Instruction</TypeOfObject>
        </InterviewerInstructionReference>
      </QuestionItem>
      |
      node = Nokogiri(text).children
      Importers::XML::DDI::Question.new(instrument).question_item_node(node)
      response_domain = code_list.reload.response_domain
      assert_equal(response_domain.min_responses, 1)
      assert_equal(response_domain.max_responses, 1)
    end
  end

  describe ".XML_node" do
    it "should record link to instruction" do
      instrument = FactoryBot.create(:instrument, study: 'uk.alspac')
      question_item = FactoryBot.create(:question_item, instrument: instrument)
      code_list = FactoryBot.create(:code_list, instrument: instrument)
      instruction = FactoryBot.create(:instruction, instrument: instrument)
      instruction.add_urn(instruction.urn)
      code_list.add_urn(code_list.urn)
      text = %Q|
      <QuestionItem>
        <URN>#{question_item.urn}</URN>
        <UserAttributePair>
          <AttributeKey>extension:Label</AttributeKey>
          <AttributeValue>{"en-GB":"A1 a"}</AttributeValue>
        </UserAttributePair>
        <QuestionItemName>
          <String xml:lang="en-GB">qi_A1_a</String>
        </QuestionItemName>
        <QuestionText audienceLanguage="en-GB">
          <LiteralText>
            <Text>The school gives high priority to raising pupils' standards of achievement</Text>
          </LiteralText>
        </QuestionText>
        <CodeDomain>
          <CodeListReference>
            <URN>#{code_list.urn}</URN>
            <TypeOfObject>CodeList</TypeOfObject>
          </CodeListReference>
          <ResponseCardinality minimumResponses="1" maximumResponses="1"></ResponseCardinality>
        </CodeDomain>
        <InterviewerInstructionReference>
          <URN>#{instruction.urn}</URN>
          <TypeOfObject>Instruction</TypeOfObject>
        </InterviewerInstructionReference>
      </QuestionItem>
      |
      node = Nokogiri(text).children.first
      Importers::XML::DDI::Question.new(instrument).XML_node(node)
      question_item = QuestionItem.last
      assert_equal(instruction.reload.question_items, [question_item])
    end
  end
end

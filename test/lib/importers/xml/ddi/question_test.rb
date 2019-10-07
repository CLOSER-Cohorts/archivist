require 'test_helper'
require 'active_support/core_ext/hash/conversions'

class Importers::XML::DDI::QuestionTest < ActiveSupport::TestCase

  describe ".question_item_node" do
    it "should record response cardinality for code list" do
      instrument = FactoryBot.create(:instrument, study: 'uk.alspac')
      question_item = FactoryBot.create(:question_item, instrument: instrument)
      code_list = FactoryBot.create(:code_list, instrument: instrument)
      text = %Q|
      <QuestionItem>
        <URN>#{question_item.urn}</URN>
        <UserAttributePair>
          <AttributeKey>extension:Label</AttributeKey>
          <AttributeValue>{"en-GB":"A1 a"}</AttributeValue>
        </UserAttributePair>
        <QuestionItemName>
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
      </QuestionItem>
      |
      node = Nokogiri(text).children
      Importers::XML::DDI::Question.new(instrument).question_item_node(node)
    end
  end
end

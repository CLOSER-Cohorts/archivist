require 'test_helper'
require 'active_support/core_ext/hash/conversions'

class Importers::XML::DDI::CodeListTest < ActiveSupport::TestCase

  describe ".XML_node" do
    it "should record codes" do
      instrument = FactoryBot.create(:instrument, study: 'uk.alspac')
      code_list = FactoryBot.create(:code_list, instrument: instrument)
      instruction = FactoryBot.create(:instruction, instrument: instrument)
      code_list.add_urn(code_list.urn)
      text = %Q|
        <CodeList>
        <URN>#{code_list.urn}</r:URN>
        <Label>
        <Content xml:lang="en-GB">cs_traceinfoeng_choice</r:Content>
        </Label>
        <Code>
        <URN>urn:ddi:uk.iser:UKHLS_Covid_Sept_2020-co-010717:1.0.0</URN>
        <CategoryReference>
        <URN>urn:ddi:uk.iser:UKHLS_Covid_Sept_2020-ca-008746:1.0.0</URN>
        <TypeOfObject>Category</TypeOfObject>
        </CategoryReference>
        <Value>1</Value>
        </Code>
        <Code>
        <URN>urn:ddi:uk.iser:UKHLS_Covid_Sept_2020-co-010718:1.0.0</URN>
        <CategoryReference>
        <URN>urn:ddi:uk.iser:UKHLS_Covid_Sept_2020-ca-008721:1.0.0</URN>
        <TypeOfObject>Category</TypeOfObject>
        </CategoryReference>
        <Value>2</Value>
        </Code>
        </CodeList>
      |
      node = Nokogiri(text).children
      Importers::XML::DDI::CodeList.new(instrument).XML_node(node)
      raise Code.all.inspect
    end
  end
end

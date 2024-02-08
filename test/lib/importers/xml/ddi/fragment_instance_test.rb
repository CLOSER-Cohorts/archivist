require 'test_helper'
require 'active_support/core_ext/hash/conversions'

class Importers::XML::DDI::FragmentInstanceTest < ActiveSupport::TestCase

  describe ".parse" do
    before do
      @instrument = FactoryBot.create(:instrument, study: 'uk.alspac', agency: 'uk.cls.bxs70', prefix: 'bcs_86_mo')
      @xml = %Q|
        <ddi:FragmentInstance xmlns:ddi="ddi:instance:3_2">
            <ddi:Fragment xmlns:r="ddi:reusable:3_2">
                <QuestionItem xmlns="ddi:datacollection:3_2" isUniversallyUnique="true" versionDate="2020-02-05T14:08:21Z">
                    <r:URN>urn:ddi:uk.cls.bcs70:bcs_86_mo-qi-026543:1.0.0</r:URN>
                    <r:Agency>uk.cls.bcs70</r:Agency>
                    <r:ID>bcs_86_mo-qi-026543</r:ID>
                    <r:Version>1.0.0</r:Version>
                    <QuestionItemName>
                        <r:String xml:lang="en-GB">qi_1</r:String>
                    </QuestionItemName>
                    <QuestionText audienceLanguage="en-GB">
                        <LiteralText>
                            <Text>
                              Write down one way in which the advertisement limits the type of people who would apply for the flat.
                            </Text>
                        </LiteralText>
                    </QuestionText>
                    <StructuredMixedResponseDomain>
                        <ResponseDomainInMixed>
                            <CodeDomain blankIsMissingValue="false">
                                <r:CodeListReference>
                                    <r:URN>urn:ddi:uk.cls.bcs70:bcs_86_mo-cl-010247:1.0.0</r:URN>
                                    <r:Agency>uk.cls.bcs70</r:Agency>
                                    <r:ID>bcs_86_mo-cl-010247</r:ID>
                                    <r:Version>1.0.0</r:Version>
                                    <r:TypeOfObject>CodeList</r:TypeOfObject>
                                </r:CodeListReference>
                                <r:ResponseCardinality minimumResponses="1" maximumResponses="2" />
                            </CodeDomain>
                        </ResponseDomainInMixed>
                        <ResponseDomainInMixed>
                            <DateTimeDomain blankIsMissingValue="false">
                                <r:DateTypeCode>Date</r:DateTypeCode>
                            </DateTimeDomain>
                        </ResponseDomainInMixed>
                        <ResponseDomainInMixed>
                            <NumericDomain blankIsMissingValue="false">
                                <r:NumberRange>
                                    <r:Low isInclusive="false">0</r:Low>
                                </r:NumberRange>
                                <r:NumericTypeCode>Integer</r:NumericTypeCode>
                                <r:Label>
                                    <r:Content xml:lang="en-GB">How many</r:Content>
                                </r:Label>
                            </NumericDomain>
                        </ResponseDomainInMixed>
                        <ResponseDomainInMixed>
                            <TextDomain blankIsMissingValue="false" maxLength="200" minLength="0">
                              <r:Label>
                                <r:Content xml:lang="en-GB">Text Label</r:Content>
                              </r:Label>
                            </TextDomain>
                        </ResponseDomainInMixed>
                    </StructuredMixedResponseDomain>
                    <InterviewerInstructionReference>
                        <r:URN>urn:ddi:uk.cls.bcs70:bcs_86_mo-ii-015479:1.0.0</r:URN>
                        <r:Agency>uk.cls.bcs70</r:Agency>
                        <r:ID>bcs_86_mo-ii-015479</r:ID>
                        <r:Version>1.0.0</r:Version>
                        <r:TypeOfObject>Instruction</r:TypeOfObject>
                    </InterviewerInstructionReference>
                </QuestionItem>
            </ddi:Fragment>
            <ddi:Fragment xmlns:r="ddi:reusable:3_2">
                <CodeList xmlns="ddi:logicalproduct:3_2" isUniversallyUnique="true" versionDate="2016-06-08T16:37:09Z">
                    <r:URN>urn:ddi:uk.cls.bcs70:bcs_86_mo-cl-010247:1.0.0</r:URN>
                    <r:Agency>uk.cls.bcs70</r:Agency>
                    <r:ID>bcs_86_mo-cl-010247</r:ID>
                    <r:Version>1.0.0</r:Version>
                    <r:Label>
                        <r:Content xml:lang="en-GB">c_Yes_No</r:Content>
                    </r:Label>
                    <Code isUniversallyUnique="true">
                        <r:URN>urn:ddi:uk.cls.bcs70:bcs_86_mo-co-049129:1.0.0</r:URN>
                        <r:Agency>uk.cls.bcs70</r:Agency>
                        <r:ID>bcs_86_mo-co-049129</r:ID>
                        <r:Version>1.0.0</r:Version>
                        <r:CategoryReference>
                            <r:URN>urn:ddi:uk.cls.bcs70:bcs_86_mo-ca-248370:1.0.0</r:URN>
                            <r:Agency>uk.cls.bcs70</r:Agency>
                            <r:ID>bcs_86_mo-ca-248370</r:ID>
                            <r:Version>1.0.0</r:Version>
                            <r:TypeOfObject>Category</r:TypeOfObject>
                        </r:CategoryReference>
                        <r:Value>1</r:Value>
                    </Code>
                    <Code isUniversallyUnique="true">
                        <r:URN>urn:ddi:uk.cls.bcs70:bcs_86_mo-co-049130:1.0.0</r:URN>
                        <r:Agency>uk.cls.bcs70</r:Agency>
                        <r:ID>bcs_86_mo-co-049130</r:ID>
                        <r:Version>1.0.0</r:Version>
                        <r:CategoryReference>
                            <r:URN>urn:ddi:uk.cls.bcs70:bcs_86_mo-ca-039196:1.0.0</r:URN>
                            <r:Agency>uk.cls.bcs70</r:Agency>
                            <r:ID>bcs_86_mo-ca-039196</r:ID>
                            <r:Version>1.0.0</r:Version>
                            <r:TypeOfObject>Category</r:TypeOfObject>
                        </r:CategoryReference>
                        <r:Value>2</r:Value>
                    </Code>
                </CodeList>
            </ddi:Fragment>
            <ddi:Fragment xmlns:r="ddi:reusable:3_2">
                <Category xmlns="ddi:logicalproduct:3_2" isUniversallyUnique="true" versionDate="2016-08-31T11:22:22.6042781Z" isMissing="false">
                    <r:URN>urn:ddi:uk.cls.bcs70:bcs_86_mo-ca-248370:1.0.0</r:URN>
                    <r:Agency>uk.cls.bcs70</r:Agency>
                    <r:ID>bcs_86_mo-ca-248370</r:ID>
                    <r:Version>1.0.0</r:Version>
                    <r:Label>
                        <r:Content xml:lang="en-GB">Yes uxx</r:Content>
                    </r:Label>
                </Category>
            </ddi:Fragment>
            <ddi:Fragment xmlns:r="ddi:reusable:3_2">
                <Category xmlns="ddi:logicalproduct:3_2" isUniversallyUnique="true" versionDate="2016-08-31T11:22:22.6042781Z" isMissing="false">
                    <r:URN>urn:ddi:uk.cls.bcs70:bcs_86_mo-ca-039196:1.0.0</r:URN>
                    <r:Agency>uk.cls.bcs70</r:Agency>
                    <r:ID>bcs_86_mo-ca-039196</r:ID>
                    <r:Version>1.0.0</r:Version>
                    <r:Label>
                        <r:Content xml:lang="en-GB">No</r:Content>
                    </r:Label>
                </Category>
            </ddi:Fragment>
            <ddi:Fragment xmlns:r="ddi:reusable:3_2">
                <Instruction xmlns="ddi:datacollection:3_2" isUniversallyUnique="true" versionDate="2020-02-05T14:08:21Z">
                    <r:URN>urn:ddi:uk.cls.bcs70:bcs_86_mo-ii-015479:1.0.0</r:URN>
                    <r:Agency>uk.cls.bcs70</r:Agency>
                    <r:ID>bcs_86_mo-ii-015479</r:ID>
                    <r:Version>1.0.0</r:Version>
                    <InstructionText audienceLanguage="en-GB">
                        <LiteralText>
                            <Text> This is the interview instruction </Text>
                        </LiteralText>
                    </InstructionText>
                </Instruction>
            </ddi:Fragment>
        </ddi:FragmentInstance>
      |
    end
    it "should parse fragments" do
      assert_difference('Category.count', 2) do
        assert_difference('CodeList.count', 1) do
          assert_difference('Code.count', 2) do
            assert_difference('Instruction.count', 1) do
              Importers::XML::DDI::FragmentInstance.new(@xml, @instrument).process      
              assert_equal('urn:ddi:uk.cls.bxs70:bcs_86_mo-qi-026543:1.0.0', QuestionItem.last.urn)
              assert_equal('urn:ddi:uk.cls.bxs70:bcs_86_mo-ii-015479:1.0.0', Instruction.last.urn)
              assert_equal('urn:ddi:uk.cls.bxs70:bcs_86_mo-ca-248370:1.0.0', Category.last.urn)
            end
          end
        end
      end
    end
  end
end

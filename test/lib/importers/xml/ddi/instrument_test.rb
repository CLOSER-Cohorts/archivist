require 'test_helper'
require 'active_support/core_ext/hash/conversions'

class Importers::XML::DDI::InstrumentTest < ActiveSupport::TestCase
  fixtures [] # remove all fixtures
  describe ".import" do
    it "should record urns" do      
      # Define the path to the XML file
      file_path = Rails.root.join('test', 'support', 'import_test.xml')
      
      # Read the content of the XML file
      xml_content = File.read(file_path)
      document = FactoryBot.create(:document, file_contents: xml_content)

      Importers::XML::DDI::Instrument.new(document.id).import

      assert_equal("urn:ddi:uk.alspac:alspac_10_yayl_staging-ii-35090:1.0.0", Instruction.last.urn)
      assert_equal("urn:ddi:uk.alspac:alspac_10_yayl_staging-qi-270296:1.0.0", QuestionItem.last.urn)
      assert_equal("urn:ddi:uk.alspac:alspac_10_yayl_staging-qg-15237:1.0.0", QuestionGrid.last.urn)
      assert_equal("urn:ddi:uk.alspac:alspac_10_yayl_staging-ca-419176:1.0.0", Category.last.urn)
      assert_equal("urn:ddi:uk.alspac:alspac_10_yayl_staging-cl-112522:1.0.0", CodeList.last.urn)
      assert_equal("urn:ddi:uk.alspac:alspac_10_yayl_staging-co-575762:1.0.0", Code.last.urn)
      assert_equal("urn:ddi:uk.alspac:alspac_10_yayl_staging-if-400910:1.0.0", CcCondition.last.urn)      
      assert_equal("urn:ddi:uk.alspac:alspac_10_yayl_staging-lp-400815:1.0.0", CcLoop.last.urn)      
      assert_equal("urn:ddi:uk.alspac:alspac_10_yayl_staging-qc-400939:1.0.0", CcQuestion.last.urn)      
      assert_equal("urn:ddi:uk.alspac:alspac_10_yayl_staging-se-400930:1.0.0", CcSequence.last.urn)            
      assert_equal("urn:ddi:uk.alspac:alspac_10_yayl_staging-si-400941:1.0.0", CcStatement.last.urn)
    end
  end
end

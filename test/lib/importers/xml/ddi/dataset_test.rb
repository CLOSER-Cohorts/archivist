require 'test_helper'
require 'active_support/core_ext/hash/conversions'

class Importers::XML::DDI::DatasetTest < ActiveSupport::TestCase
  fixtures [] # remove all fixtures
  describe ".import" do
    it "should record urns" do      
      # Define the path to the XML file
      file_path = Rails.root.join('test', 'support', 'import_dataset_test.xml')
      
      # Read the content of the XML file
      xml_content = File.read(file_path)
      document = FactoryBot.create(:document, file_contents: xml_content)
      import = FactoryBot.create(:import, document: document)
      assert_equal(import.reload.state, nil)
      Importers::XML::DDI::Dataset.new(document.id).import(import_id: import.id)
      import.reload
      assert_equal(import.state, 'failure')
    end
  end
end

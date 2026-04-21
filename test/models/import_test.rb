require 'test_helper'

class ImportTest < ActiveSupport::TestCase
  setup do
    @import = create(:import)
  end

  test "belongs to an dataset" do
    assert_kind_of Dataset, @import.dataset
  end

  test "stores filename from document at create time" do
    doc = Document.create!(filename: 'test-file.xml')
    instrument = Instrument.first || create(:instrument)
    import = Import.create!(
      document: doc,
      dataset: Dataset.first || create(:dataset),
      instrument: instrument,
      import_type: 'ImportJob::Instrument',
      state: 'pending'
    )
    assert_equal 'test-file.xml', import.reload.filename
  end

  test "filename persists after document_id is nullified" do
    doc = Document.create!(filename: 'historical.xml')
    instrument = Instrument.first || create(:instrument)
    import = Import.create!(
      document: doc,
      dataset: Dataset.first || create(:dataset),
      instrument: instrument,
      import_type: 'ImportJob::Instrument',
      state: 'pending'
    )
    Import.where(id: import.id).update_all(document_id: nil)
    assert_equal 'historical.xml', import.reload.filename
  end
end

require 'test_helper'

class ImportsControllerTest < ActionController::TestCase
  test "index JSON includes filename for import with no document_id" do
    doc = Document.create!(filename: 'instrument-data.xml')
    instrument = Instrument.first || create(:instrument)
    import = Import.create!(
      document: doc,
      dataset: Dataset.first || create(:dataset),
      instrument: instrument,
      import_type: 'ImportJob::Instrument',
      state: 'pending'
    )
    Import.where(id: import.id).update_all(document_id: nil)

    get :index, format: :json
    assert_response :success

    body = JSON.parse(response.body)
    row = body.find { |r| r['id'] == import.id }
    assert_not_nil row, "Import not found in response"
    assert_equal 'instrument-data.xml', row['filename']
  end
end

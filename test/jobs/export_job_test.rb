require 'test_helper'

class ExportJobTest < ActiveSupport::TestCase
  def setup
    # Use FactoryBot to ensure valid objects
    @instrument = create(:instrument, prefix: 'test_instrument')
    @dataset = create(:dataset, name: 'Test Dataset', filename: 'test_dataset.xml')
    @export = create(:export, state: :pending)

    # Mock the document creation process
    @mock_document = Minitest::Mock.new
    @mock_document.expect(:save!, true)

    # Stub the `Document.new` call to return the mocked document
    Document.stub :new, @mock_document do
      yield if block_given?
    end
  end

  def teardown
    # Ensure all expectations on mocks are verified
    @mock_document.verify
  end

  test 'instrument export job performs successfully' do
    exporter_mock = Minitest::Mock.new
    exporter_mock.expect(:add_root_attributes, true)
    exporter_mock.expect(:export_instrument, true, [@instrument])
    %i[rp iis cs cls qis qgs is ccs].each do |step|
      exporter_mock.expect("build_#{step}".to_sym, true)
    end

    Exporters::XML::DDI::Instrument.stub :new, exporter_mock do
      ExportJob::Instrument.new.perform(@instrument.id, @export.id)
    end

    assert_equal 'test_instrument.xml', @mock_document.filename
  end

  test 'dataset export job performs successfully' do
    exporter_mock = Minitest::Mock.new
    exporter_mock.expect(:run, true, [@dataset])

    Exporters::XML::DDI::Dataset.stub :new, exporter_mock do
      ExportJob::Dataset.new.perform(@dataset.id)
    end

    assert_equal 'test_dataset.xml', @mock_document.filename
  end

  test 'instrument export job handles invalid export ID gracefully' do
    assert_raises(ActiveRecord::RecordNotFound) do
      ExportJob::Instrument.new.perform(@instrument.id, 9999)
    end
  end

  test 'instrument export job logs errors on failure' do
    failing_exporter = Minitest::Mock.new
    failing_exporter.expect(:add_root_attributes, proc { raise StandardError, 'Simulated failure' })

    Exporters::XML::DDI::Instrument.stub :new, failing_exporter do
      job = ExportJob::Instrument.new
      assert_raises(StandardError) { job.perform(@instrument.id, @export.id) }

      logs = Export.find(@export.id).log
      assert_includes logs, 'Simulated failure'
    end
  end

  test 'instrument complete export job performs successfully' do
    exporter_mock = Minitest::Mock.new
    exporter_mock.expect(:add_root_attributes, true)
    exporter_mock.expect(:export_instrument, true, [@instrument])
    %i[rp iis cs cls qis qgs is ccs].each do |step|
      exporter_mock.expect("build_#{step}".to_sym, true)
    end

    Exporters::XML::DDI::InstrumentComplete.stub :new, exporter_mock do
      ExportJob::InstrumentComplete.new.perform(@instrument.id, @export.id)
    end

    assert_equal 'test_instrument_complete.xml', @mock_document.filename
  end
end
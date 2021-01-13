require 'test_helper'

class TestLogger < Logger
  def initialize
    @strio = StringIO.new
    super(@strio)
  end

  def messages
    @strio.string
  end
end

class ExportJob::InstrumentTest < ActiveSupport::TestCase
  setup do
    @logger = TestLogger.new
    Rails.logger = @logger
    @instrument = FactoryBot.create(:instrument, study: 'uk.alspac')
  end

  describe ".perform" do
    it "work" do
      ExportJob::Instrument.perform(@instrument.id)
      assert @logger.messages !~ /Job Failed/i, 'Job failed in logger'
    end
  end
end

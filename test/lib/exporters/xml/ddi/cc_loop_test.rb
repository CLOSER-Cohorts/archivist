require 'test_helper'
require 'active_support/core_ext/hash/conversions'

class Exporters::XML::DDI::CcLoopTest < ActiveSupport::TestCase

  setup do
    @instrument = FactoryBot.create(:instrument)
    @cc_loop = FactoryBot.create(:cc_loop, instrument: @instrument)
  end

  it "should create the selp URN correctly so that it matches" do
    exported_xml = Exporters::XML::DDI::CcLoop.new(Nokogiri::XML::Document.new).V3_2(@cc_loop).to_xml
    urns = exported_xml.scan(/<r:URN>([^<]*-selp-[^<]*)<\/r:URN>/).flatten
    urns
    assert_equal 1, urns.uniq.size
  end
end

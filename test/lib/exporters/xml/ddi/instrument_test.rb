require 'test_helper'
require 'active_support/core_ext/hash/conversions'

class Exporters::XML::DDI::InstrumentTest < ActiveSupport::TestCase

  setup do
    @instrument = instruments :Instrument_2
    @exporter = Exporters::XML::DDI::Instrument.new
    @exporter.add_root_attributes
    @exporter.export_instrument(@instrument)
    @exporter.build_rp
    @exporter.build_iis
    @exporter.build_cs
    @exporter.build_cls
    @exporter.build_qis
    @exporter.build_qgs
    @exporter.build_is
    @exporter.build_ccs
  end

  it "should create a scheme with just the entries related to control constructs" do
    assert_references_has_logical_product('d:QuestionItem', 'r:QuestionReference', 'qi')
    assert_references_has_logical_product('d:QuestionGrid', 'r:QuestionReference', 'qg')
    assert_references_has_logical_product('l:CodeList', 'r:CodeListReference', 'cl')
    assert_references_has_logical_product('l:Category', 'r:CategoryReference', 'ca')
  end
end

def assert_references_has_logical_product(logical_product_name, reference_name, prefix=nil)
  xml = @exporter.doc.to_xml(&:no_empty_tags)
  noko = Nokogiri::XML xml
  references_urns = noko.xpath("//#{reference_name}//r:URN").map(&:inner_text).uniq.sort
  urns = noko.xpath("//#{logical_product_name}/r:URN").map(&:inner_text).uniq.sort
  if prefix
    references_urns = references_urns.select{|urn| urn =~ /#{prefix}-/}
    urns = urns.select{|urn| urn =~ /#{prefix}-/}
  end
  refute_empty urns
  refute_empty references_urns
  assert_equal urns, references_urns
end

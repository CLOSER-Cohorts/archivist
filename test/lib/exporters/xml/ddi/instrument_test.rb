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
    xml = @exporter.doc.to_xml(&:no_empty_tags)
    noko = Nokogiri::XML xml
    assert_references_has_logical_product(noko, 'd:QuestionItem', 'r:QuestionReference', 'qi')
    assert_references_has_logical_product(noko, 'd:QuestionGrid', 'r:QuestionReference', 'qg')
    assert_references_has_logical_product(noko, 'l:CodeList', 'r:CodeListReference', 'cl')
    assert_references_has_logical_product(noko, 'l:Category', 'r:CategoryReference', 'ca')
    assert_unique_logical_product(noko, 'd:QuestionItem')
    assert_unique_logical_product(noko, 'd:QuestionGrid')
    assert_unique_logical_product(noko, 'l:CodeList')
    assert_unique_logical_product(noko, 'l:Category')
  end
end

def assert_references_has_logical_product(xml, logical_product_name, reference_name, prefix=nil)
  references_urns = xml.xpath("//#{reference_name}//r:URN").map(&:inner_text).uniq.sort
  urns = xml.xpath("//#{logical_product_name}/r:URN").map(&:inner_text).uniq.sort
  if prefix
    references_urns = references_urns.select{|urn| urn =~ /#{prefix}-/}
    urns = urns.select{|urn| urn =~ /#{prefix}-/}
  end

  refute_empty urns
  refute_empty references_urns
  assert_equal urns, references_urns
end

def assert_unique_logical_product(xml, logical_product_name)
  urns = xml.xpath("//#{logical_product_name}/r:URN").map(&:inner_text)
  duplicate_urns = urns.group_by{ |e| e }.select { |k, v| v.size > 1 }
  assert_empty duplicate_urns
end

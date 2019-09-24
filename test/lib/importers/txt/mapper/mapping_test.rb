require 'test_helper'
require 'active_support/core_ext/hash/conversions'

class Importers::TXT::Mapper::MappingTest < ActiveSupport::TestCase

  setup do
    @instrument = instruments :Instrument_2
  end

  describe "where instrument already has qv mappings" do
    describe "qv mappings from tab delimited text file" do
      it "should create a new mappings for the question and variables" do
        new_txt = "qc_A1\tA003\nqc_A2_a\tA002\n"
        doc = Document.create(file: new_txt, item: @instrument)
        Importers::TXT::Mapper::Mapping.new(doc.id, {:object=>@instrument.id.to_s}).import
        assert_equal [['qc_A1', 'a003'],['qc_A2_a', 'a002']], @instrument.reload.qv_mappings.map{|qv| [qv.question, qv.variable]}
      end
    end
    describe "qv mappings from tab delimited text file does not match any mappings" do
      it "should create a new mappings for the question and variables" do
        new_txt = "qc_A1\tAlolz\nqc_A2_a\tAlolz\n"
        doc = Document.create(file: new_txt, item: @instrument)
        Importers::TXT::Mapper::Mapping.new(doc.id, {:object=>@instrument.id.to_s}).import
        assert_empty @instrument.reload.qv_mappings
      end
    end
  end
end

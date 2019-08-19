require 'test_helper'
require 'active_support/core_ext/hash/conversions'

class Importers::TXT::Mapper::TopicVTest < ActiveSupport::TestCase

  setup do
    @dataset = datasets 'Dataset_1'
  end

  describe "where dataset already has tv mappings" do
    describe "tv mappings from tab delimited text file" do
      it "should create a new mappings for the topic and variables" do
        new_txt = "aln\t10320\nqlet\t10320\n"
        doc = Document.create(file: new_txt, item: @dataset)
        Importers::TXT::Mapper::TopicV.new(doc.id, {:object=>@dataset.id.to_s}).import
        assert_equal(@dataset.variables.find_by_name('aln').fully_resolved_topic_code, '10320')
        assert_equal(@dataset.variables.find_by_name('qlet').fully_resolved_topic_code, '10320')
      end
    end
    describe "tv mappings from tab delimited text file does not match any mappings" do
      it "should create a new mappings for the topic and variables" do
        Link.create(target_type: 'Variable', target_id: 156092, topic_id: 2)
        assert_equal('102', @dataset.variables.find_by_name('kw0001').fully_resolved_topic_code)
        new_txt = "aln\t10320\nkw0001\t10320\n"
        doc = Document.create(file: new_txt, item: @dataset)
        Importers::TXT::Mapper::TopicV.new(doc.id, {:object=>@dataset.id.to_s}).import
        assert_equal('10320', @dataset.variables.find_by_name('kw0001').fully_resolved_topic_code)
      end
    end
  end
end

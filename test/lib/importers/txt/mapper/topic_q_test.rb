require 'test_helper'
require 'active_support/core_ext/hash/conversions'

class Importers::TXT::Mapper::TopicQTest < ActiveSupport::TestCase

  setup do
    @instrument = FactoryBot.create(:instrument)
    @topic = FactoryBot.create(:topic, code: 102)
    @other_topic = FactoryBot.create(:topic, code: 10320)
    @aln = FactoryBot.create(:cc_question, instrument: @instrument, label: 'aln', topic: @topic)
    @qlet = FactoryBot.create(:cc_question, instrument: @instrument, label: 'qlet', topic: @topic)
    @kw0001 = FactoryBot.create(:cc_question, instrument: @instrument, label: 'kw0001', topic: @topic)
  end

  describe "where instrument already has tq mappings" do
    describe "tq mappings from tab delimited text file" do
      it "should create a new mappings for the topic and variables" do
        new_txt = "#{@instrument.control_construct_scheme}\taln\t10320\n#{@instrument.control_construct_scheme}\tqlet\t10320\n"
        doc = Document.create(file: new_txt, item: @instrument)
        Importers::TXT::Mapper::TopicQ.new(doc.id, {:object=>@instrument.id.to_s}).import
        assert_equal(@aln.reload.fully_resolved_topic_code, '10320')
        assert_equal(@qlet.reload.fully_resolved_topic_code, '10320')
      end
    end
    describe "tq mappings from tab delimited text file does not match any mappings" do
      it "should create a new mappings for the topic and variables" do
        new_txt = "#{@instrument.control_construct_scheme}\taln\t10320\n"
        doc = Document.create(file: new_txt, item: @instrument)
        Importers::TXT::Mapper::TopicQ.new(doc.id, {:object=>@instrument.id.to_s}).import
        assert_equal('0', @kw0001.reload.fully_resolved_topic_code)
      end
    end
    describe "instrument from the tab delimited text file does not match the instrument for the import" do
      it "should mark the import has an error" do
        other_instrument = FactoryBot.create(:instrument)
        new_txt = "#{other_instrument.control_construct_scheme}\taln\t10320\n"
        import = FactoryBot.create(:import, instrument: @instrument, import_type: 'ImportJob::TopicV')
        doc = Document.create(file: new_txt, item: @instrument)
        Importers::TXT::Mapper::TopicQ.new(doc.id, {:object=>@instrument.id.to_s, :import_id => import.id}).import
        import = import.reload
        assert_equal('failure', import.state)
        assert_equal(import.parsed_log.first[:outcome], I18n.t('importers.txt.mapper.topic_q.record_invalid_control_construct_scheme', control_construct_scheme_from_line: other_instrument.control_construct_scheme, control_construct_scheme_from_object: @instrument.control_construct_scheme))
      end
    end
    describe "tab delimited text contains less than 3 columns" do
      it "should mark the import has an error" do
        new_txt = "aln\naln\t123\n"
        import = FactoryBot.create(:import, instrument: @instrument, import_type: 'ImportJob::TopicV')
        doc = Document.create(file: new_txt, item: @instrument)
        Importers::TXT::Mapper::TopicQ.new(doc.id, {:object=>@instrument.id.to_s, :import_id => import.id}).import
        import = import.reload
        assert_equal('failure', import.state)
        assert_equal(import.parsed_log.first[:outcome], I18n.t('importers.txt.mapper.topic_q.wrong_number_of_columns', actual_number_of_columns: 1))
        assert_equal(import.parsed_log[1][:outcome], I18n.t('importers.txt.mapper.topic_q.wrong_number_of_columns', actual_number_of_columns: 2))
      end
    end
  end
end

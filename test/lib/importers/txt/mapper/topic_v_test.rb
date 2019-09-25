require 'test_helper'
require 'active_support/core_ext/hash/conversions'

class Importers::TXT::Mapper::TopicVTest < ActiveSupport::TestCase

  setup do
    @dataset = datasets 'Dataset_1'
  end

  describe "where dataset already has tv mappings" do
    describe "tv mappings from tab delimited text file" do
      it "should create a new mappings for the topic and variables" do
        var = @dataset.variables.find_by_name('aln')
        new_txt = "#{@dataset.instance_name}\taln\t10320\n#{@dataset.instance_name}\tqlet\t10320\n"
        doc = Document.create(file: new_txt, item: @dataset)
        Importers::TXT::Mapper::TopicV.new(doc.id, {:object=>@dataset.id.to_s}).import
        assert_equal(@dataset.variables.find_by_name('aln').fully_resolved_topic_code, '10320')
        assert_equal(@dataset.variables.find_by_name('qlet').fully_resolved_topic_code, '10320')
      end
    end
    describe "tv mappings from tab delimited text file does not match any mappings" do
      it "should create a new mappings for the topic and variables" do
        var = @dataset.variables.find_by_name('kw0001')
        Link.create(target_type: 'Variable', target_id: var.id, topic_id: 2)
        assert_equal('102', var.reload.fully_resolved_topic_code)
        new_txt = "#{@dataset.instance_name}\taln\t10320\n"
        doc = Document.create(file: new_txt, item: @dataset)
        Importers::TXT::Mapper::TopicV.new(doc.id, {:object=>@dataset.id.to_s}).import
        assert_equal('0', var.reload.fully_resolved_topic_code)
      end
    end
    describe "dataset from the tab delimited text file does not match the dataset for the import" do
      it "should mark the import has an error" do
        var = @dataset.variables.find_by_name('kw0001')
        other_dataset = FactoryBot.create(:dataset)
        Link.create(target_type: 'Variable', target_id: var.id, topic_id: 2)
        assert_equal('102', var.reload.fully_resolved_topic_code)
        new_txt = "#{other_dataset.instance_name}\taln\t10320\n"
        import = FactoryBot.create(:import, dataset: @dataset, import_type: 'ImportJob::TopicV')
        doc = Document.create(file: new_txt, item: @dataset)
        Importers::TXT::Mapper::TopicV.new(doc.id, {:object=>@dataset.id.to_s, :import_id => import.id}).import
        import = import.reload
        assert_equal('failure', import.state)
        assert_equal(import.parsed_log.first[:outcome], I18n.t('importers.txt.mapper.topic_v.record_invalid_dataset', dataset_from_line: other_dataset.instance_name, dataset_from_object: @dataset.instance_name))
      end
    end
    describe "tab delimited text contains less than 3 columns" do
      it "should mark the import has an error" do
        var = @dataset.variables.find_by_name('kw0001')
        Link.create(target_type: 'Variable', target_id: var.id, topic_id: 2)
        assert_equal('102', var.reload.fully_resolved_topic_code)
        new_txt = "aln\naln\t123\n"
        import = FactoryBot.create(:import, dataset: @dataset, import_type: 'ImportJob::TopicV')
        doc = Document.create(file: new_txt, item: @dataset)
        Importers::TXT::Mapper::TopicV.new(doc.id, {:object=>@dataset.id.to_s, :import_id => import.id}).import
        import = import.reload
        assert_equal('failure', import.state)
        assert_equal(import.parsed_log.first[:outcome], I18n.t('importers.txt.mapper.topic_v.wrong_number_of_columns', actual_number_of_columns: 1))
        assert_equal(import.parsed_log[1][:outcome], I18n.t('importers.txt.mapper.topic_v.wrong_number_of_columns', actual_number_of_columns: 2))
      end
    end
  end
end

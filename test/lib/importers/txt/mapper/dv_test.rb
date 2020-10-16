require 'test_helper'
require 'active_support/core_ext/hash/conversions'

class Importers::TXT::Mapper::DVTest < ActiveSupport::TestCase

  setup do
    @dataset = FactoryBot.create(:dataset)
    @source_variable = FactoryBot.create(:variable, dataset: @dataset)
    @derived_variable = FactoryBot.create(:variable, dataset: @dataset)
    @derived_variable.src_variables << @source_variable
  end

  describe "where instrument already has dv mappings" do
    describe "dv mappings from tab delimited text file" do
      it "should create a new mappings for the source and derived variables" do
        source_variable = FactoryBot.create(:variable, dataset: @dataset)
        new_txt = "#{@dataset.instance_name}\t#{@derived_variable}\t#{@dataset.instance_name}\t#{source_variable.name}\n"
        import = FactoryBot.create(:import, dataset: @dataset, import_type: 'ImportJob::DV')
        doc = Document.create(file: new_txt, item: @dataset)
        Importers::TXT::Mapper::DV.new(doc.id, {:object=>@dataset.id.to_s, :import_id => import.id}).import
        import = import.reload
        assert_equal('success', import.state)
        last_dv_mapping = @dataset.reload.dv_mappings.last
        assert_equal [source_variable.name, @derived_variable.name], [last_dv_mapping.source, last_dv_mapping.variable]
      end
    end
  end
  describe "dataset from the tab delimited text file does not match the instrument for the import" do
    it "should mark the import has an error" do
      other_dataset = FactoryBot.create(:dataset)
      new_txt = "#{other_dataset.instance_name}\t#{@derived_variable}\t#{@dataset.instance_name}\t#{@source_variable.name}\n"
      import = FactoryBot.create(:import, dataset: @dataset, import_type: 'ImportJob::DV')
      doc = Document.create(file: new_txt, item: @dataset)
      Importers::TXT::Mapper::DV.new(doc.id, {:object=>@dataset.id.to_s, :import_id => import.id}).import
      import = import.reload
      assert_equal('failure', import.state)
      assert_equal(import.parsed_log.first[:outcome], I18n.t('importers.txt.mapper.dv.record_invalid_dataset', dataset_from_line: other_dataset.instance_name, dataset_from_object: @dataset.instance_name))
    end
  end
  describe "tab delimited text contains less than 4 columns" do
    it "should mark the import has an error" do
      new_txt = "#{@dataset.instance_name}\t#{@derived_variable}\t#{@dataset.instance_name}\n#{@dataset.instance_name}\t#{@derived_variable}\n"
      import = FactoryBot.create(:import, dataset: @dataset, import_type: 'ImportJob::DV')
      doc = Document.create(file: new_txt, item: @dataset)
      Importers::TXT::Mapper::DV.new(doc.id, {:object=>@dataset.id.to_s, :import_id => import.id}).import
      import = import.reload
      assert_equal('failure', import.state)
      assert_equal(import.parsed_log.first[:outcome], I18n.t('importers.txt.mapper.dv.wrong_number_of_columns', actual_number_of_columns: 3))
      assert_equal(import.parsed_log[1][:outcome], I18n.t('importers.txt.mapper.dv.wrong_number_of_columns', actual_number_of_columns: 2))
    end
  end
  describe "tab delimited text contains does not match a source" do
    it "should mark the import has an error" do
      source_variable = FactoryBot.create(:variable, dataset: @dataset)
      new_txt = "#{@dataset.instance_name}\t#{@derived_variable}\t#{@dataset.instance_name}\tno_src_found\n"
      import = FactoryBot.create(:import, dataset: @dataset, import_type: 'ImportJob::DV')
      doc = Document.create(file: new_txt, item: @dataset)
      Importers::TXT::Mapper::DV.new(doc.id, {:object=>@dataset.id.to_s, :import_id => import.id}).import
      import = import.reload
      assert_equal('failure', import.state)
      assert_equal(import.parsed_log.first[:outcome], I18n.t('importers.txt.mapper.dv.no_source_found'))
    end
  end
  describe "tab delimited text contains does not match a variable" do
    it "should mark the import has an error" do
      source_variable = FactoryBot.create(:variable, dataset: @dataset)
      new_txt = "#{@dataset.instance_name}\tno_variable_found\t#{@dataset.instance_name}\t#{source_variable.name}\n"
      import = FactoryBot.create(:import, dataset: @dataset, import_type: 'ImportJob::DV')
      doc = Document.create(file: new_txt, item: @dataset)
      Importers::TXT::Mapper::DV.new(doc.id, {:object=>@dataset.id.to_s, :import_id => import.id}).import
      import = import.reload
      assert_equal('failure', import.state)
      assert_equal(import.parsed_log.first[:outcome], I18n.t('importers.txt.mapper.dv.no_variable_found'))
    end
  end
end

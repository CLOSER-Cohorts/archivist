require 'test_helper'
require 'active_support/core_ext/hash/conversions'

class Importers::TXT::Mapper::MappingTest < ActiveSupport::TestCase

  describe "where instrument already has qv mappings" do
    describe "qv mappings from tab delimited text file" do
      it "should create a new mappings for the question and variables" do
      dataset = FactoryBot.create(:dataset)
      variable = FactoryBot.create(:variable, dataset: dataset)
      instrument = FactoryBot.create(:instrument, datasets: [dataset])
      cc_question = FactoryBot.create(:cc_question, instrument: instrument, label: 'qc_abc_123')
      cc_question.maps.create(variable: variable)
      map = QvMapping.where(question: cc_question.label).first
      new_txt = "#{instrument.control_construct_scheme}\t#{cc_question.label}\t#{dataset.instance_name}\t#{variable.name}\n"
      import = FactoryBot.create(:import, instrument: instrument, import_type: 'ImportJob::Mapping')
      doc = Document.create(file: new_txt, item: instrument)
      Importers::TXT::Mapper::Mapping.new(doc.id, {:object=>instrument.id.to_s, :import_id => import.id}).import
      import = import.reload
      assert_equal('success', import.state)
      assert_equal [[cc_question.label, variable.name]], instrument.reload.qv_mappings.map{|qv| [qv.question, qv.variable]}
      end
    end
    describe "dataset is not linked to the instrument" do
      it "should create a new mappings for the question and variables" do
      dataset = FactoryBot.create(:dataset)
      variable = FactoryBot.create(:variable, dataset: dataset)
      instrument = FactoryBot.create(:instrument, datasets: [dataset])
      cc_question = FactoryBot.create(:cc_question, instrument: instrument, label: 'qc_abc_123')
      cc_question.maps.create(variable: variable)
      map = QvMapping.where(question: cc_question.label).first
      new_txt = "#{instrument.control_construct_scheme}\t#{cc_question.label}\t#{dataset.instance_name}x\t#{variable.name}\n"
      import = FactoryBot.create(:import, instrument: instrument, import_type: 'ImportJob::Mapping')
      doc = Document.create(file: new_txt, item: instrument)
      Importers::TXT::Mapper::Mapping.new(doc.id, {:object=>instrument.id.to_s, :import_id => import.id}).import
      import = import.reload
      assert_equal('failure', import.state)
      assert_equal(import.parsed_log.first[:outcome], I18n.t('importers.txt.mapper.mapping.dataset_not_associated_to_instrument', dataset: "#{dataset.instance_name}x"))      
      end
    end    
    describe "qv mappings from tab delimited text file does not match any mappings" do
      it "should not create any mappings for the question and variables" do
        instrument = FactoryBot.create(:instrument)
        new_txt = "qc_A1\tAlolz\nqc_A2_a\tAlolz\n"
        doc = Document.create(file: new_txt, item: instrument)
        Importers::TXT::Mapper::Mapping.new(doc.id, {:object=>instrument.id.to_s}).import
        assert_empty instrument.reload.qv_mappings
      end
    end
  end
  describe "instrument from the tab delimited text file does not match the instrument for the import" do
    it "should mark the import has an error" do
      other_instrument = FactoryBot.create(:instrument)
      dataset = FactoryBot.create(:dataset)
      variable = FactoryBot.create(:variable, dataset: dataset)
      instrument = FactoryBot.create(:instrument)
      cc_question = FactoryBot.create(:cc_question, instrument: instrument, label: 'qc_abc_123')
      cc_question.maps.create(variable: variable)
      map = QvMapping.where(question: cc_question.label).first
      new_txt = "#{other_instrument.control_construct_scheme}\t#{cc_question.label}\t#{dataset.instance_name}\t#{variable.name}}\n"
      import = FactoryBot.create(:import, instrument: instrument, import_type: 'ImportJob::Mapping')
      doc = Document.create(file: new_txt, item: instrument)
      Importers::TXT::Mapper::Mapping.new(doc.id, {:object=>instrument.id.to_s, :import_id => import.id}).import
      import = import.reload
      assert_equal('failure', import.state)
      assert_equal(import.parsed_log.first[:outcome], I18n.t('importers.txt.mapper.mapping.record_invalid_control_construct_scheme', control_construct_scheme_from_line: other_instrument.control_construct_scheme, control_construct_scheme_from_object: instrument.control_construct_scheme))
    end
  end
  describe "tab delimited text contains less than 4 columns" do
    it "should mark the import has an error" do
      dataset = FactoryBot.create(:dataset)
      variable = FactoryBot.create(:variable, dataset: dataset)
      instrument = FactoryBot.create(:instrument)
      cc_question = FactoryBot.create(:cc_question, instrument: instrument, label: 'qc_abc_123')
      cc_question.maps.create(variable: variable)
      map = QvMapping.where(question: cc_question.label).first
      new_txt = "#{instrument.control_construct_scheme}\t#{cc_question.label}\t#{dataset.instance_name}\n#{instrument.control_construct_scheme}\t#{variable.name}}\n"
      import = FactoryBot.create(:import, instrument: instrument, import_type: 'ImportJob::Mapping')
      doc = Document.create(file: new_txt, item: instrument)
      Importers::TXT::Mapper::Mapping.new(doc.id, {:object=>instrument.id.to_s, :import_id => import.id}).import
      import = import.reload
      assert_equal('failure', import.state)
      assert_equal(import.parsed_log.first[:outcome], I18n.t('importers.txt.mapper.mapping.wrong_number_of_columns', actual_number_of_columns: 3))
      assert_equal(import.parsed_log[1][:outcome], I18n.t('importers.txt.mapper.mapping.wrong_number_of_columns', actual_number_of_columns: 2))
    end
  end

  describe "partial QV file that does not cover all questions in the instrument" do
    it "marks the import as failure and logs unmapped questions" do
      dataset = FactoryBot.create(:dataset)
      variables = (1..5).map { FactoryBot.create(:variable, dataset: dataset) }
      instrument = FactoryBot.create(:instrument, datasets: [dataset])
      cc_questions = (1..5).map { |n| FactoryBot.create(:cc_question, instrument: instrument, label: "qc_partial_#{n}") }
      mapped_rows = cc_questions.first(3).map do |q|
        "#{instrument.control_construct_scheme}\t#{q.label}\t#{dataset.instance_name}\t#{variables.first.name}"
      end
      new_txt = mapped_rows.join("\n") + "\n"
      import = FactoryBot.create(:import, instrument: instrument, import_type: 'ImportJob::Mapping')
      doc = Document.create(file: new_txt, item: instrument)
      Importers::TXT::Mapper::Mapping.new(doc.id, { object: instrument.id.to_s, import_id: import.id }).import
      import = import.reload
      assert_equal('failure', import.state)
      log = import.parsed_log
      assert_equal 5, log.length
      saved_outcomes = log.first(3).map { |e| e[:outcome] }
      assert saved_outcomes.all? { |o| o == 'Record Saved' }, "Expected first 3 entries to be 'Record Saved'"
      unmapped_outcomes = log.last(2).map { |e| e[:outcome] }
      assert unmapped_outcomes.all? { |o| o.include?('Record Invalid') }, "Expected last 2 entries to mention Record Invalid"
      assert unmapped_outcomes.any? { |o| o.include?(cc_questions[3].label) }
      assert unmapped_outcomes.any? { |o| o.include?(cc_questions[4].label) }
    end

    it "keeps state as success when all questions are covered" do
      dataset = FactoryBot.create(:dataset)
      variables = (1..3).map { FactoryBot.create(:variable, dataset: dataset) }
      instrument = FactoryBot.create(:instrument, datasets: [dataset])
      cc_questions = (1..3).map { |n| FactoryBot.create(:cc_question, instrument: instrument, label: "qc_full_#{n}") }
      rows = cc_questions.each_with_index.map do |q, i|
        "#{instrument.control_construct_scheme}\t#{q.label}\t#{dataset.instance_name}\t#{variables[i].name}"
      end
      new_txt = rows.join("\n") + "\n"
      import = FactoryBot.create(:import, instrument: instrument, import_type: 'ImportJob::Mapping')
      doc = Document.create(file: new_txt, item: instrument)
      Importers::TXT::Mapper::Mapping.new(doc.id, { object: instrument.id.to_s, import_id: import.id }).import
      import = import.reload
      assert_equal('success', import.state)
    end
  end
end

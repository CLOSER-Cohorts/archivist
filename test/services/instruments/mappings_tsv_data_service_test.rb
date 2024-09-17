require 'test_helper'

class Instruments::MappingsTsvDataServiceTest < ActiveSupport::TestCase
  def setup
    # Create topics
    @topic1 = FactoryBot.create(:topic, code: 'T1')
    @topic2 = FactoryBot.create(:topic, code: 'T2')

    # Create datasets
    @dataset1 = FactoryBot.create(:dataset, filename: 'DS1.ddi32.rp.xml')
    @dataset2 = FactoryBot.create(:dataset, filename: 'DS2.ddi32.rp.xml')

    # Create variables used in cc_questions
    @variable1 = FactoryBot.create(:variable, name: 'VAR1', label: 'Variable 1', topic: @topic1, dataset: @dataset1)
    @variable2 = FactoryBot.create(:variable, name: 'VAR2', label: 'Variable 2', topic: @topic2, dataset: @dataset2)

    # Create unmapped variables
    @variable3 = FactoryBot.create(:variable, name: 'VAR3', label: 'Variable 3', topic: @topic1, dataset: @dataset1)
    @variable4 = FactoryBot.create(:variable, name: 'VAR4', label: 'Variable 4', topic: @topic2, dataset: @dataset2)
    @unmapped_variables = [@variable3, @variable4]

    # Create categories
    @category1 = FactoryBot.create(:category, label: 'Category 1')
    @category2 = FactoryBot.create(:category, label: 'Category 2')

    # Create code lists and associate codes
    @horizontal_code_list = FactoryBot.create(:code_list)
    @vertical_code_list = FactoryBot.create(:code_list)

    # Create codes and associate them with code lists
    @code1 = FactoryBot.create(:code, category: @category1, code_list: @horizontal_code_list)
    @code2 = FactoryBot.create(:code, category: @category2, code_list: @vertical_code_list)

    # Create questions
    @question1 = FactoryBot.create(:question_item,
                                   literal: 'What is your age?')

    @question2 = FactoryBot.create(:question_item,
                                   literal: 'What is your gender?')

    @question3 = FactoryBot.create(:question_grid,
                                   literal: 'What is your favorite color?',
                                   horizontal_code_list: @horizontal_code_list,
                                   vertical_code_list: @vertical_code_list)

    # Create cc_questions
    @cc_question1 = FactoryBot.create(:cc_question, question: @question1, label: 'Q1', topic: @topic1)
    @cc_question2 = FactoryBot.create(:cc_question, question: @question2, label: 'Q2', topic: @topic2)
    @cc_question3 = FactoryBot.create(:cc_question, question: @question3, label: 'Q3', topic: @topic1)

    # Associate variables and maps
    @cc_question2.variables << @variable1
    @map1 = FactoryBot.create(:map, variable: @variable2, x: nil, y: nil, source: @cc_question3)

    # Create instrument with prefix
    @instrument = FactoryBot.create(:instrument, prefix: 'INST1')
    @instrument.cc_questions << @cc_question1
    @instrument.cc_questions << @cc_question2
    @instrument.cc_questions << @cc_question3

    # Initialize the service
    @service = Instruments::MappingsTsvDataService.new(@instrument, @unmapped_variables)
  end

  def test_generate_tsv_data
    tsv_data = @service.generate_tsv_data

    expected_data = [
      {
        label: "Q1$0;0",
        question_text: 'What is your age?',
        question_topic_id: 'T1',
        questionnaire_prefix: 'INST1',
        variable_name: nil,
        variable_topic_id: nil,
        variable_label: nil,
        dataset_prefix: nil
      },
      {
        label: "Q2$0;0",
        question_text: 'What is your gender?',
        question_topic_id: 'T2',
        questionnaire_prefix: 'INST1',
        variable_name: 'VAR1',
        variable_topic_id: 'T1',
        variable_label: 'Variable 1',
        dataset_prefix: 'DS1'
      },
      {
        label: "Q3$0;0",
        question_text: 'What is your favorite color?',
        question_topic_id: 'T1',
        questionnaire_prefix: 'INST1',
        variable_name: 'VAR2',
        variable_topic_id: 'T2',
        variable_label: 'Variable 2',
        dataset_prefix: 'DS2'
      },
      {
        label: "Q3$1;1",
        question_text: 'What is your favorite color? Category 2',
        question_topic_id: 'T1',
        questionnaire_prefix: 'INST1',
        variable_name: nil,
        variable_topic_id: nil,
        variable_label: nil,
        dataset_prefix: nil
      },
      {
        label: nil,
        question_text: nil,
        question_topic_id: nil,
        questionnaire_prefix: nil,
        variable_name: 'VAR3',
        variable_topic_id: 'T1',
        variable_label: 'Variable 3',
        dataset_prefix: 'DS1'
      },
      {
        label: nil,
        question_text: nil,
        question_topic_id: nil,
        questionnaire_prefix: nil,
        variable_name: 'VAR4',
        variable_topic_id: 'T2',
        variable_label: 'Variable 4',
        dataset_prefix: 'DS2'
      }
    ]

    assert_equal expected_data, tsv_data
  end
end
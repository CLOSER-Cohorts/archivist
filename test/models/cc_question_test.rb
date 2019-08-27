require 'test_helper'

class CcQuestionTest < ActiveSupport::TestCase
  setup do
    @cc_question = cc_questions :CcQuestion_4
    topic = topics :Topic_2
    @cc_question.topic = topic
    @cc_question.save!
  end

  test "belongs to an instrument" do
    assert_kind_of Instrument, @cc_question.instrument
  end

  test "has one question" do
    assert_not_nil @cc_question.question
  end

  test "belongs to response unit" do
    assert_kind_of ResponseUnit, @cc_question.response_unit
  end

  test "can read parent construct" do
    unless @cc_question.parent.nil?
      assert_kind_of ParentalConstruct, @cc_question.parent
    else
      assert ParentalConstruct, nil
    end
  end

  test "when construct parent is 'nil'" do
    @cc_question.parent = nil
    unless @cc_question.parent.nil?
      assert_kind_of ParentalConstruct, @cc_question.parent
    else
      assert ParentalConstruct, nil
    end
  end

  test "can create cc_question" do
    i = instruments :Instrument_1
    assert_kind_of CcStatement, i.cc_statements.create
  end

  test "set a new parent" do
    seq = @cc_question.instrument.cc_sequences.create
    @cc_question.parent = seq
    assert_equal @cc_question.parent, seq
  end

  test "has one topic" do
    assert_kind_of Topic, @cc_question.topic
  end

  test "has many variables" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @cc_question.variables
  end
  describe 'topic inheritance' do
    describe 'with variable' do
      describe 'and variable has no topic set' do
        describe 'and no topic set for question' do
          it 'return nil for resolved_topic' do
            question = create(:cc_question, topic: nil)
            variable = create(:variable, questions: [question], topic: nil)

            assert_nil question.resolved_topic
          end
        end
        describe 'and topic set for question' do
          it 'return question topic for resolved_topic' do
            topic = create(:topic)
            question = create(:cc_question, topic: topic)
            variable = create(:variable, questions: [question], topic: nil)

            assert_equal(topic, question.resolved_topic)
          end
        end
      end
      describe 'and variable has topic set' do
        describe 'and no topic set for question' do
          it 'return variable topic for resolved_topic' do
            topic = create(:topic)
            question = create(:cc_question, topic: nil)
            variable = create(:variable, questions: [question], topic: topic)

            assert_equal variable.topic, question.resolved_topic
          end
        end
        describe 'and topic set for question' do
          it 'return question topic for resolved_topic' do
            topic = create(:topic)
            question = create(:cc_question, topic: topic)
            other_topic = create(:topic)
            variable = create(:variable, questions: [question], topic: topic)

            assert_equal topic, question.resolved_topic
          end
        end
      end
    end
    describe 'topic conflict' do
      describe 'with no associated variables' do
        describe 'and question has topic set' do
          describe 'when we associate the question to a variable that has a conflicting topic set' do
            it 'return error message if variable topic != question topic' do
              topic = create(:topic, name: 'Variable Topic')
              variable = create(:variable, questions: [], topic: topic)
              variable.save
              other_topic = create(:topic, name: 'Question Topic')
              question = create(:cc_question, topic: other_topic)
              question.variables << variable
              refute question.valid?
              assert_not_nil question.errors[:topic], 'no validation error for topic present'
              assert_equal I18n.t('activerecord.errors.models.cc_question.attributes.topic.conflict', topics: topic.to_s, variables: question.variables.to_sentence), question.errors[:topic].first
            end
          end
        end
      end
      describe 'with associated variables' do
        describe 'and question has no topic set' do
          describe 'when we associate the question to a variable that has a conflicting topic set' do
            it 'set the topic as expected' do
              topic = create(:topic)
              question = create(:cc_question, topic: nil)
              variable = create(:variable, questions: [question])
              variable.topic = topic
              assert variable.valid?
              variable.save
              assert_equal topic, variable.topic
            end
          end
          describe 'the existing associated variable has a topic set' do
            describe 'when we associate the question to a variable that has a conflicting topic set' do
              it 'return error message if variable topic != question topic' do
                topic = create(:topic, name: 'Variable Topic')
                existing_variable = create(:variable, questions: [], topic: topic)
                other_topic = create(:topic, name: 'Conflicting Variable Topic')
                conflicting_variable = create(:variable, questions: [], topic: other_topic)
                question = create(:cc_question, topic: nil, variables: [existing_variable])
                assert question.valid?
                question.variables << conflicting_variable
                refute question.valid?
                assert_not_nil question.errors[:topic], 'no validation error for topic present'
                assert_equal I18n.t('activerecord.errors.models.cc_question.attributes.resolved_topic.variables_conflict', new_variables: conflicting_variable, new_topics: other_topic, existing_topic: topic), question.errors[:topic].first
              end
            end
          end
        end
      end
    end
  end
end

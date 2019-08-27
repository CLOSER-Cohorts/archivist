require 'test_helper'

class VariableTest < ActiveSupport::TestCase
  setup do
    topic = create(:topic)
    @variable = create(:variable, topic: topic)
  end

  test "belongs to dataset" do
    assert_kind_of Dataset, @variable.dataset
  end

  test "has many questions" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @variable.questions
  end

  test "has many sources" do
    assert_kind_of Array, @variable.sources
  end

  test "has many source variables" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @variable.src_variables
  end

  test "has many derived variables" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @variable.der_variables
  end

  test "has one topic" do
    assert_kind_of Topic, @variable.topic
  end

  describe 'topic inheritance' do
    describe 'with question' do
      describe 'and question has no topic set' do
        describe 'and no topic set for variable' do
          it 'return nil for resolved_topic' do
            question = create(:cc_question, topic: nil)
            variable = create(:variable, questions: [question], topic: nil)

            assert_nil variable.resolved_topic
          end
        end
        describe 'and topic set for variable' do
          it 'return variable topic for resolved_topic' do
            topic = create(:topic)
            question = create(:cc_question, topic: nil)
            variable = create(:variable, questions: [question], topic: topic)

            assert_equal(topic, variable.resolved_topic)
          end
        end
      end
      describe 'and question has topic set' do
        describe 'and no topic set for variable' do
          it 'return question topic for resolved_topic' do
            question = create(:cc_question)
            variable = create(:variable, questions: [question], topic: nil)

            assert_equal question.topic, variable.resolved_topic
          end
        end
        describe 'and topic set for variable' do
          it 'return variable topic for resolved_topic' do
            topic = create(:topic)
            question = create(:cc_question, topic: topic)
            variable = create(:variable, questions: [question], topic: topic)

            assert_equal topic, variable.resolved_topic
          end
        end
      end
    end
    describe 'topic conflict' do
      describe 'with no associated question' do
        describe 'and variable has topic set' do
          describe 'when variable is assigned to question with set topic' do
            it 'return error message if variable topic != question topic' do
              topic = create(:topic)
              variable = create(:variable, questions: [], topic: topic)
              variable.save
              other_topic = create(:topic)
              question = create(:cc_question, topic: other_topic)
              variable.questions << question
              refute variable.valid?
              assert_not_nil variable.errors[:topic], 'no validation error for topic present'
              assert_equal I18n.t('activerecord.errors.models.variable.attributes.topic.conflict', topics: other_topic.to_s, questions: variable.questions.to_sentence), variable.errors[:topic].first
            end
          end
        end
      end
      describe 'with associated question' do
        describe 'and question has no topic set' do
          describe 'and topic already set for variable' do
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
        end
        describe 'and question has topic set' do
          describe 'and no topic set for variable' do
            it 'return error message if variable topic != question topic' do
              question_topic = create(:topic, name: 'Topic 123')
              question = create(:cc_question, topic: question_topic, label: 'Question ABC')
              topic = create(:topic)
              variable = build(:variable, questions: [question], topic: topic)
              refute variable.valid?
              assert_not_nil variable.errors[:topic], 'no validation error for topic present'
              assert_equal I18n.t('activerecord.errors.models.variable.attributes.topic.conflict', topics: 'Topic 123', questions: variable.questions.to_sentence), variable.errors[:topic].first
            end
          end
        end
      end
    end
  end
end

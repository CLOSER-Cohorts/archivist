require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  setup do
    @topic = topics :Topic_32
    @topic_2 = topics :Topic_2
  end

  test 'flattened_nest topics count' do
    assert Topic.flattened_nest.count == Topic.count
  end

  test 'flattened_nest where parent_id is Nil' do
    topics = Topic.where(parent_id: nil).flattened_nest.sort
    last_topic_with_nil_parent = Topic.where(id: 15)
    assert topics.count == 16
    assert_equal topics[-1], last_topic_with_nil_parent[0]
    assert_kind_of Topic, @topic.parent
  end

  test "has a parent" do
    topics = Topic.where.not(parent_id: nil)
    last_topic_with_parent = Topic.where(id: 124)
    assert topics.flattened_nest.count == 0
    assert_kind_of Topic, @topic.parent
  end

  test 'Topics at top level do not have a parent' do
    refute @topic_2.parent_id
  end

  test "has children" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @topic.children
  end
end

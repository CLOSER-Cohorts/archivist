require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  setup do
    @topic = topics :one
  end

  test "has a parent" do
    assert_kind_of Topic, @topic.parent
  end

  test "has children" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @topic.children
  end
end

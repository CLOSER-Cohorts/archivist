require 'test_helper'

class CcConditionTest < ActiveSupport::TestCase
  setup do
    debugger
    @cc_condition = cc_conditions :CcCondition_1
  end

  test "can read parent construct" do
    assert_kind_of ::ParentalConstruct, @cc_condition.parent
  end

  test "set a new parent" do
    seq = @cc_condition.instrument.cc_sequences.create
    @cc_condition.parent = seq
    assert_equal @cc_condition.parent, seq
  end

  test "has many children" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @cc_condition.children
  end

  test "has one topic" do
    assert_kind_of Topic, @cc_condition.topic
  end

  #test "push new construct into children" do
  #  assert_difference '@cc_condition.children.length', 1 do
  #@cc_condition.children << CcCondition.new
  #  end
  #end
end

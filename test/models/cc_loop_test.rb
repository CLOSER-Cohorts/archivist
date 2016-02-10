require 'test_helper'

class CcLoopTest < ActiveSupport::TestCase
  setup do
    @cc_loop = cc_loops :one
  end

  test "belongs to an instrument" do
    assert_kind_of Instrument, @cc_loop.instrument
  end

  test "has one cc" do
    assert_kind_of ControlConstruct, @cc_loop.cc
  end

  test "can read parent construct" do
    assert_kind_of Construct, @cc_loop.parent
  end

  test "set a new parent" do
    seq = @cc_loop.instrument.cc_sequences.create
    @cc_loop.parent = seq
    assert_equal @cc_loop.parent, seq
  end

  test "has one topic" do
    assert_kind_of Topic, @cc_loop.topic
  end

  test "has many children" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @cc_loop.children
  end
end

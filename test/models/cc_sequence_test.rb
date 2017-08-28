require 'test_helper'

class CcSequenceTest < ActiveSupport::TestCase
  setup do
    @cc_sequence = cc_sequences :CcSequence_3
  end

  test "belongs to an instrument" do
    assert_kind_of Instrument, @cc_sequence.instrument
  end

  test "can read parent construct" do
    assert_kind_of ParentalConstruct, @cc_sequence.parent
  end

  test "set a new parent" do
    seq = @cc_sequence.instrument.cc_sequences.create
    @cc_sequence.parent = seq
    assert_equal @cc_sequence.parent, seq
  end

  test "has one topic" do
    assert_kind_of Topic, @cc_sequence.topic
  end

  test "has many children" do
    assert_kind_of Enumerable, @cc_sequence.children
  end
end

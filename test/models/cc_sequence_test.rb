require 'test_helper'

class CcSequenceTest < ActiveSupport::TestCase
  setup do
    @cc_sequence = cc_sequences :two
  end
  
  test "has one cc" do
    assert_kind_of ControlConstruct, @cc_sequence.cc
  end
  
  test "can read parent construct" do
    assert_kind_of Construct, @cc_sequence.parent
  end
  
  test "set a new parent" do
  	seq = CcSequence.new
  	seq.save!
  	@cc_sequence.parent = seq
  	assert_equal @cc_sequence.parent, seq
  end
  
  test "has many children" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @cc_sequence.children
  end
end

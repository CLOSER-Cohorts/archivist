require 'test_helper'

class CcQuestionTest < ActiveSupport::TestCase
  setup do
    @cc_question = cc_questions :one
  end
  
  test "has one question" do
    assert_not_nil @cc_question.question
  end
  
  test "has one cc" do
    assert_kind_of ControlConstruct, @cc_question.cc
  end
  
  test "belongs to response unit" do
    assert_kind_of ResponseUnit, @cc_question.response_unit
  end
  
  test "can read parent construct" do
    assert_kind_of Construct, @cc_question.parent
  end
  
  test "set a new parent" do
  	seq = CcSequence.new
  	seq.save!
  	@cc_question.parent = seq
  	assert_equal @cc_question.parent, seq
  end
end

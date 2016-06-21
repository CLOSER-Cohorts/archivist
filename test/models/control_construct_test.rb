require 'test_helper'

class ControlConstructTest < ActiveSupport::TestCase
  setup do
    @cc_qi = control_constructs :ControlConstruct_12
    @cc_qg = control_constructs :ControlConstruct_13
  end

  test "has one construct" do
    assert_not_nil @cc_qi.construct
  end
  test "can access queston item" do
    assert_kind_of QuestionItem, @cc_qi.construct.question
  end
end

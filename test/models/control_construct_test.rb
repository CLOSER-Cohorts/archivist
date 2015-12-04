require 'test_helper'

class ControlConstructTest < ActiveSupport::TestCase
  setup do
    @cc_qi = control_constructs :qi
    @cc_qg = control_constructs :qg
    #@cc_co = control_constructs :co
    #@cc_se = control_constructs :se
    #@cc_st = control_constructs :st
    #@cc_lo = control_constructs :lo
  end
  
  test "has one construct" do
    assert_not_nil @cc_qi.construct
  end
  test "can access queston item" do
    assert_kind_of QuestionItem, @cc_qi.construct.question
  end
end

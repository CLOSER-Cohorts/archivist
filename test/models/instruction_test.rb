require 'test_helper'

class InstructionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @instruction = instructions :one
  end

  test "belongs to an instrument" do
    assert_kind_of Instrument, @instruction.instrument
  end

  test "has many questions" do
    assert_not_nil @instruction.questions
  end

  test "has many question_items" do
    assert_not_nil @instruction.question_items
  end

  test "has many question_grids" do
    assert_not_nil @instruction.question_grids
  end
end

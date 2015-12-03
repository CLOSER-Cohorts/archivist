require 'test_helper'

class QuestionGridTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @question_grid = question_grids :one
  end
  
  test "has one instruction" do
    assert_not_nil @question_grid.instruction
  end

  test "has many response domains" do
    assert_not_nil @question_grid.response_domains
  end

  test "has many response domain codes" do
    assert_not_nil @question_grid.response_domain_codes
  end

  test "has many response domain datetimes" do
    assert_not_nil @question_grid.response_domain_datetimes
  end
  
  test "has many response domain numerics" do
    assert_not_nil @question_grid.response_domain_numerics
  end

  test "has many response domain texts" do
    assert_not_nil @question_grid.response_domain_texts
  end
end

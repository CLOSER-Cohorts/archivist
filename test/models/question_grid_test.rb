require 'test_helper'

class QuestionGridTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @question_grid = question_grids :one
  end
  
  test "belongs to an instrument" do
    assert_kind_of Instrument, @question_grid.instrument
  end
  
  test "has one instruction" do
    assert_kind_of Instruction, @question_grid.instruction
  end

  test "has many response domains" do
    assert_kind_of Array, @question_grid.response_domains
  end

  test "has many response domain codes" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @question_grid.response_domain_codes
  end

  test "has many response domain datetimes" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @question_grid.response_domain_datetimes
  end
  
  test "has many response domain numerics" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @question_grid.response_domain_numerics
  end

  test "has many response domain texts" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @question_grid.response_domain_texts
  end
  
  test "has many question constructs" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @question_grid.cc_questions
    assert_equal @question_grid.constructs, @question_grid.cc_questions
  end
end

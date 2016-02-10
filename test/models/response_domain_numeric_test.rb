require 'test_helper'

class ResponseDomainNumericTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @response_domain_numeric = response_domain_numerics :one
  end

  test "belongs to an instrument" do
    assert_kind_of Instrument, @response_domain_numeric.instrument
  end

  test "has many questions" do
    assert_not_nil @response_domain_numeric.questions
  end

  test "has many question items" do
    assert_not_nil @response_domain_numeric.question_items
  end

  test "has many question grids" do
    assert_not_nil @response_domain_numeric.question_grids
  end
end

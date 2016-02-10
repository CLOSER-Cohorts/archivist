require 'test_helper'

class ResponseDomainCodeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @response_domain_code = response_domain_codes :one
  end

  test "belongs to an instrument" do
    assert_kind_of Instrument, @response_domain_code.instrument
  end

  test "has many questions" do
    assert_not_nil @response_domain_code.questions
  end

  test "has many question items" do
    assert_not_nil @response_domain_code.question_items
  end

  test "has many question grids" do
    assert_not_nil @response_domain_code.question_grids
  end
end

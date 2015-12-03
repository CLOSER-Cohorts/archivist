require 'test_helper'

class ResponseDomainDatetimeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @response_domain_datetime = response_domain_datetimes :one
  end

  test "has many questions" do
    assert_not_nil @response_domain_datetime.questions
  end

  test "has many question items" do
    assert_not_nil @response_domain_datetime.question_items
  end

  test "has many question grids" do
    assert_not_nil @response_domain_datetime.question_grids
  end
end

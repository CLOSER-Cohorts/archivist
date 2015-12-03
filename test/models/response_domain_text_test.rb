require 'test_helper'

class ResponseDomainTextTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @response_domain_text = response_domain_texts :one
  end

  test "has many questions" do
    assert_not_nil @response_domain_text.questions
  end

  test "has many question items" do
    assert_not_nil @response_domain_text.question_items
  end

  test "has many question grids" do
    assert_not_nil @response_domain_text.question_grids
  end
end

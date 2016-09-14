require 'test_helper'

class CodeListTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @code_list = code_lists :CodeList_1
  end

  test "belongs to an instrument" do
    assert_kind_of Instrument, @code_list.instrument
  end

  test "has many codes" do
    assert_not_nil @code_list.codes
  end

  test "has many categories" do
    assert_not_nil @code_list.categories
    assert_equal @code_list.codes.count, @code_list.categories.count
  end

  test "has one response domain" do
    assert_not_nil @code_list.response_domain
    code_list = code_lists :CodeList_27
    assert_nil code_list.response_domain
  end

  test "make into code answer" do
    code_list = code_lists :CodeList_27
    assert_difference 'ResponseDomainCode.count', 1 do
      code_list.response_domain = true
    end
  end

  test "remove code answer" do
    assert_difference 'ResponseDomainCode.count', -1 do
      @code_list.response_domain = false
    end
  end

  test "do nothing to code answer" do
    code_list = code_lists :CodeList_27
    assert_difference 'ResponseDomainCode.count', 0 do
      code_list.response_domain = false
    end
    assert_difference 'ResponseDomainCode.count', 0 do
      @code_list.response_domain = true
    end
  end
end

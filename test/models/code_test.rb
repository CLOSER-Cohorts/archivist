require 'test_helper'

class CodeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  setup do
    @code = codes :Code_1
  end

  test "can read label" do
    assert_not_nil @code.label
  end

  test "can write to label with new category" do
    assert_difference 'Category.count', 1 do
      @code.label = 'totally new category'
    end
  end

  test "can write to label with existing category" do
    assert_difference 'Category.count', 0 do
      @code.label = 'Yes'
    end
  end
end

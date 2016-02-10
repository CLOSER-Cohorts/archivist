require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  setup do
    @category = categories :one
  end

  test "belongs to an instrument" do
    assert_kind_of Instrument, @category.instrument
  end
end

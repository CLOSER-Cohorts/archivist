require 'test_helper'

class CodeJobTest < ActiveSupport::TestCase
  setup do
    @code = codes :Code_1
  end

  test "can read label" do
    assert_not_nil @code.label
  end
end

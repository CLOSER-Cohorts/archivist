require 'test_helper'

class ResponseUnitTest < ActiveSupport::TestCase
  setup do
    @response_unit = response_units :ResponseUnit_1
  end

  test "belongs to an instrument" do
    assert_kind_of Instrument, @response_unit.instrument
  end

  test "has many questions" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @response_unit.questions
  end
end

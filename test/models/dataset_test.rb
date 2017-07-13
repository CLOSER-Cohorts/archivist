require 'test_helper'

class DatasetTest < ActiveSupport::TestCase
  setup do
    @dataset = datasets :Dataset_1
  end

  test "has many variables" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @dataset.variables
  end
end

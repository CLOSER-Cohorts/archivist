require 'test_helper'

class DatasetTest < ActiveSupport::TestCase
  setup do
    @dataset = datasets :one
  end
  
  test "has many variables" do
    assert_kind_of ActiveRecord::Associations::CollectionProxy, @dataset.variables
  end
end
